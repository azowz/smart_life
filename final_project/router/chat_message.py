from fastapi import APIRouter, Depends, HTTPException, Path, Query
from sqlalchemy.orm import Session
from typing import List

from final_project.db import get_db
from final_project.models.user import UserDB
from final_project.security import get_current_user
from final_project.schemas.chat_message import (
    ChatMessageCreate, 
    ChatMessageUpdate, 
    ChatMessageResponse
)
from final_project.services.chat_message import (
    create_message,
    update_message,
    get_message,
    delete_message,
    get_user_messages,
    get_messages_by_entity
)

router = APIRouter(prefix="/chat-messages", tags=["chat-messages"])

@router.post("/", response_model=ChatMessageResponse, status_code=201)
def create_chat_message(
    message: ChatMessageCreate, 
    db: Session = Depends(get_db)
):
    """Create a new chat message"""
    return create_message(db=db, message_data=message)

@router.get("/{message_id}", response_model=ChatMessageResponse)
def read_message(
    message_id: int = Path(..., description="The message ID"), 
    db: Session = Depends(get_db)
):
    """Get a specific message by ID"""
    db_message = get_message(db=db, message_id=message_id)
    if db_message is None:
        raise HTTPException(status_code=404, detail="Message not found")
    return db_message

@router.put("/{message_id}", response_model=ChatMessageResponse)
def update_chat_message(
    message: ChatMessageUpdate,
    message_id: int = Path(..., description="The message ID"),
    db: Session = Depends(get_db)
):
    """Update a message"""
    db_message = update_message(db=db, message_id=message_id, message_data=message)
    if db_message is None:
        raise HTTPException(status_code=404, detail="Message not found")
    return db_message

@router.delete("/{message_id}")
def delete_chat_message(
    message_id: int = Path(..., description="The message ID"), 
    db: Session = Depends(get_db),
    current_user: UserDB = Depends(get_current_user)
):
    """Delete a message (superuser only)"""
    if not current_user.superuser:
        raise HTTPException(status_code=403, detail="Not authorized")
    success = delete_message(db=db, message_id=message_id)
    if not success:
        raise HTTPException(status_code=404, detail="Message not found")
    return {"detail": "Message successfully deleted"}

@router.get("/user/{user_id}", response_model=List[ChatMessageResponse])
def read_user_messages(
    user_id: int = Path(..., description="The user ID"),
    skip: int = Query(0, description="Number of records to skip"),
    limit: int = Query(100, description="Maximum number of records to return"),
    db: Session = Depends(get_db),
    current_user: UserDB = Depends(get_current_user)
):
    """Get all messages for a specific user"""
    # Only the user or superuser can access
    if user_id != current_user.user_id and not current_user.superuser:
        raise HTTPException(status_code=403, detail="Not authorized to view these messages")
    return get_user_messages(db=db, user_id=user_id, skip=skip, limit=limit)

@router.get("/entity/{entity_type}/{entity_id}", response_model=List[ChatMessageResponse])
def read_entity_messages(
    entity_type: str = Path(..., description="The entity type"),
    entity_id: int = Path(..., description="The entity ID"),
    skip: int = Query(0, description="Number of records to skip"),
    limit: int = Query(100, description="Maximum number of records to return"),
    db: Session = Depends(get_db),
    current_user: UserDB = Depends(get_current_user)
):
    """Get all messages for a specific entity (superuser only)"""
    if not current_user.superuser:
        raise HTTPException(status_code=403, detail="Not authorized")
    return get_messages_by_entity(
        db=db, 
        entity_id=entity_id, 
        entity_type=entity_type,
        skip=skip,
        limit=limit
    )
