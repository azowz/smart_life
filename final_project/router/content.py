from typing import List, Union
from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session, or_, select

from final_project.db import ActiveSession
from final_project.models.content import ContentDB, ContentIncoming, ContentResponse  # Changed Content to ContentDB
from final_project.models.user import UserDB
from final_project.security import get_current_active_user

router = APIRouter()

# Get all contents (open to everyone)
@router.get("/", response_model=List[ContentResponse])
async def list_contents(*, session: Session = ActiveSession):
    contents = session.exec(select(ContentDB)).all()  # Changed Content to ContentDB
    return contents

# Get specific content by ID or slug
@router.get("/{id_or_slug}/", response_model=ContentResponse)
async def query_content(
    *, id_or_slug: Union[str, int], session: Session = ActiveSession
):
    content = session.exec(
        select(ContentDB).where(  # Changed Content to ContentDB
            or_(
                ContentDB.id == id_or_slug,  # Changed Content to ContentDB
                ContentDB.slug == id_or_slug,  # Changed Content to ContentDB
            )
        )
    ).first()
    
    if not content:
        raise HTTPException(status_code=404, detail="Content not found")
    
    return content

# Create new content - requires user authentication
@router.post("/", response_model=ContentResponse)
async def create_content(
    *,
    session: Session = ActiveSession,
    content: ContentIncoming,
    current_user: UserDB = Depends(get_current_active_user)
):
    # Link content to current user
    db_content = ContentDB.from_orm(content)  # Changed Content to ContentDB
    db_content.user_id = current_user.user_id
    
    session.add(db_content)
    session.commit()
    session.refresh(db_content)
    return db_content

# Update existing content - only by owner or admin
@router.patch("/{content_id}/", response_model=ContentResponse)
async def update_content(
    *,
    content_id: int,
    session: Session = ActiveSession,
    patch: ContentIncoming,
    current_user: UserDB = Depends(get_current_active_user)
):
    content = session.get(ContentDB, content_id)  # Changed Content to ContentDB
    if not content:
        raise HTTPException(status_code=404, detail="Content not found")
    
    # Verify that user owns the content or is admin
    if content.user_id != current_user.user_id and not current_user.superuser:
        raise HTTPException(status_code=403, detail="You don't own this content")
    
    # Apply updates
    patch_data = patch.dict(exclude_unset=True)
    for key, value in patch_data.items():
        setattr(content, key, value)
    
    session.commit()
    session.refresh(content)
    return content

# Delete content - only by owner or admin
@router.delete("/{content_id}/")
def delete_content(
    *,
    content_id: int,
    session: Session = ActiveSession,
    current_user: UserDB = Depends(get_current_active_user)
):
    content = session.get(ContentDB, content_id)  # Changed Content to ContentDB
    if not content:
        raise HTTPException(status_code=404, detail="Content not found")
    
    # Verify permission
    if content.user_id != current_user.user_id and not current_user.superuser:
        raise HTTPException(status_code=403, detail="You don't own this content")
    
    session.delete(content)
    session.commit()
    return {"ok": True}