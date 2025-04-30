from typing import List, Optional, Dict, Any
from sqlalchemy.orm import Session
from sqlalchemy import func, case
from datetime import datetime, timedelta
from enum import Enum
import time

from final_project.models.ai_interaction import AIInteractionDB
from final_project.schemas.ai_interaction import AIInteractionCreate, AIInteractionComplete
from final_project.services.ai_service import call_ai_api

def create_interaction(db: Session, interaction_data: AIInteractionCreate) -> AIInteractionDB:
    """Create a new AI interaction (start of the process)"""
    interaction_dict = interaction_data.dict()
    if isinstance(interaction_dict.get('interaction_type'), Enum):
        interaction_dict['interaction_type'] = interaction_dict['interaction_type'].value

    db_interaction = AIInteractionDB(**interaction_dict)
    db.add(db_interaction)
    db.commit()
    db.refresh(db_interaction)
    return db_interaction

async def complete_interaction(
    db: Session,
    interaction_id: int,
    completion_data: AIInteractionComplete
) -> Optional[AIInteractionDB]:
    """Complete an AI interaction by adding response data and calling AI API"""
    db_interaction = db.query(AIInteractionDB).filter(
        AIInteractionDB.interaction_id == interaction_id
    ).first()

    if not db_interaction:
        return None

    prompt = db_interaction.prompt

    try:
        start_time = time.time()
        ai_response = await call_ai_api(prompt)
        end_time = time.time()
        processing_time = int((end_time - start_time) * 1000)

        if "choices" in ai_response and len(ai_response["choices"]) > 0:
            choice = ai_response["choices"][0]
            response_text = (
                choice.get("message", {}).get("content")
                or choice.get("text")
                or None
            )
        else:
            response_text = None

        if not response_text:
            raise ValueError("AI did not return a usable response.")

        tokens_used = ai_response.get("usage", {}).get("total_tokens", 50)

        db_interaction.response = response_text
        db_interaction.processing_time = processing_time
        db_interaction.tokens_used = tokens_used
        db_interaction.was_successful = True

    except Exception as e:
        db_interaction.response = None
        db_interaction.processing_time = 100
        db_interaction.tokens_used = 10
        db_interaction.was_successful = False

    db.commit()
    db.refresh(db_interaction)
    return db_interaction

def get_user_interactions(
    db: Session,
    user_id: int,
    limit: int = 50,
    offset: int = 0
) -> List[AIInteractionDB]:
    """Get interactions for a specific user"""
    return db.query(AIInteractionDB).filter(
        AIInteractionDB.user_id == user_id
    ).order_by(
        AIInteractionDB.created_at.desc()
    ).limit(limit).offset(offset).all()

def get_interaction_stats(
    db: Session,
    user_id: Optional[int] = None,
    days: int = 30
) -> Dict[str, Any]:
    """Get statistics about AI interactions"""
    start_date = datetime.now() - timedelta(days=days)

    query = db.query(
        func.count().label('total_interactions'),
        func.sum(case([(AIInteractionDB.was_successful, 1)], else_=0)).label('successful_interactions'),
        func.sum(AIInteractionDB.tokens_used).label('total_tokens'),
        func.avg(AIInteractionDB.processing_time).label('avg_processing_time')
    ).filter(
        AIInteractionDB.created_at >= start_date
    )

    if user_id:
        query = query.filter(AIInteractionDB.user_id == user_id)

    result = query.first()

    return {
        'total_interactions': result.total_interactions or 0,
        'successful_interactions': result.successful_interactions or 0,
        'success_rate': (result.successful_interactions / result.total_interactions * 100) if result.total_interactions else 0,
        'total_tokens': result.total_tokens or 0,
        'avg_processing_time': result.avg_processing_time or 0,
        'period_days': days,
        'user_id': user_id
    }

def get_interaction(db: Session, interaction_id: int) -> Optional[AIInteractionDB]:
    """Get a specific interaction by ID"""
    return db.query(AIInteractionDB).filter(AIInteractionDB.interaction_id == interaction_id).first()

def get_interactions_by_type(
    db: Session,
    interaction_type: str,
    limit: int = 50,
    offset: int = 0
) -> List[AIInteractionDB]:
    """Get interactions of a specific type"""
    return db.query(AIInteractionDB).filter(
        AIInteractionDB.interaction_type == interaction_type
    ).order_by(
        AIInteractionDB.created_at.desc()
    ).limit(limit).offset(offset).all()
