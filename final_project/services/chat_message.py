from typing import List, Optional
from sqlalchemy.orm import Session
from sqlalchemy import desc

from final_project.models.chat_message import ChatMessageDB
from final_project.schemas.chat_message import ChatMessageCreate, ChatMessageUpdate


def create_message(db: Session, message_data: ChatMessageCreate) -> ChatMessageDB:
    db_message = ChatMessageDB(**message_data.dict())
    db.add(db_message)
    db.commit()
    db.refresh(db_message)
    return db_message


def update_message(db: Session, message_id: int, message_data: ChatMessageUpdate) -> Optional[ChatMessageDB]:
    db_message = db.query(ChatMessageDB).filter(ChatMessageDB.message_id == message_id).first()
    if not db_message:
        return None
    update_data = message_data.dict(exclude_unset=True)
    for key, value in update_data.items():
        setattr(db_message, key, value)
    db.commit()
    db.refresh(db_message)
    return db_message


def get_message(db: Session, message_id: int) -> Optional[ChatMessageDB]:
    return db.query(ChatMessageDB).filter(ChatMessageDB.message_id == message_id).first()


def delete_message(db: Session, message_id: int) -> bool:
    db_message = db.query(ChatMessageDB).filter(ChatMessageDB.message_id == message_id).first()
    if not db_message:
        return False
    db.delete(db_message)
    db.commit()
    return True


def get_user_messages(
    db: Session,
    user_id: int,
    skip: int = 0,
    limit: int = 100
) -> List[ChatMessageDB]:
    return db.query(ChatMessageDB).filter(
        ChatMessageDB.user_id == user_id
    ).order_by(
        desc(ChatMessageDB.created_at)
    ).offset(skip).limit(limit).all()


def get_messages_by_entity(
    db: Session,
    entity_id: int,
    entity_type: str,
    skip: int = 0,
    limit: int = 100
) -> List[ChatMessageDB]:
    return db.query(ChatMessageDB).filter(
        ChatMessageDB.related_entity_id == entity_id,
        ChatMessageDB.related_entity_type == entity_type
    ).order_by(
        desc(ChatMessageDB.created_at)
    ).offset(skip).limit(limit).all()
