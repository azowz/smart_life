from typing import List, Optional, Dict, Any
from sqlalchemy.orm import Session
from enum import Enum

from final_project.models.ai_prompt_template import AIPromptTemplateDB
from final_project.schemas.ai_prompt_template import AIPromptTemplateCreate, AIPromptTemplateUpdate

# Create a new prompt template
def create_prompt_template(db: Session, template_data: AIPromptTemplateCreate) -> AIPromptTemplateDB:
    """
    Create a new AI prompt template in the database.
    """
    # Convert Pydantic model to dictionary and handle Enum values
    template_dict = template_data.dict()
    if isinstance(template_dict.get('purpose'), Enum):
        template_dict['purpose'] = template_dict['purpose'].value  # Convert Enum to string

    db_template = AIPromptTemplateDB(**template_dict)
    db.add(db_template)
    db.commit()
    db.refresh(db_template)
    return db_template

# Update an existing prompt template
def update_prompt_template(db: Session, template_id: int, template_data: AIPromptTemplateUpdate) -> Optional[AIPromptTemplateDB]:
    """
    Update an existing prompt template in the database.
    """
    db_template = db.query(AIPromptTemplateDB).filter(
        AIPromptTemplateDB.template_id == template_id
    ).first()

    if not db_template:
        return None

    # Update only the provided fields (exclude unset fields)
    update_data = template_data.dict(exclude_unset=True)
    for key, value in update_data.items():
        if isinstance(value, Enum):
            setattr(db_template, key, value.value)  # Handle Enum values
        else:
            setattr(db_template, key, value)

    db.commit()
    db.refresh(db_template)
    return db_template

# Retrieve all active templates (optionally filtered by purpose)
def get_active_templates(db: Session, purpose: Optional[str] = None) -> List[AIPromptTemplateDB]:
    """
    Retrieve active prompt templates from the database.
    """
    query = db.query(AIPromptTemplateDB).filter(
        AIPromptTemplateDB.is_active == True
    )

    if purpose:
        query = query.filter(AIPromptTemplateDB.purpose == purpose)

    return query.order_by(AIPromptTemplateDB.name).all()

# Retrieve a single template by ID
def get_template_by_id(db: Session, template_id: int) -> Optional[AIPromptTemplateDB]:
    """
    Retrieve a prompt template by its ID.
    """
    return db.query(AIPromptTemplateDB).filter(
        AIPromptTemplateDB.template_id == template_id
    ).first()

# Render a prompt template with parameters
def render_template(template_text: str, parameters: Dict[str, Any]) -> str:
    """
    Render a prompt template with provided parameters.
    """
    rendered_text = template_text
    for key, value in parameters.items():
        placeholder = f"{{{key}}}"  # Example: {username}
        rendered_text = rendered_text.replace(placeholder, str(value))
    return rendered_text

# Delete a template by ID
def delete_template(db: Session, template_id: int) -> bool:
    """
    Delete a prompt template from the database.
    """
    db_template = db.query(AIPromptTemplateDB).filter(
        AIPromptTemplateDB.template_id == template_id
    ).first()

    if not db_template:
        return False

    db.delete(db_template)
    db.commit()
    return True
