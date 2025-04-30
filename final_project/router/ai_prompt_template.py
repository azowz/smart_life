from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List, Optional, Dict, Any

from final_project.db import get_db
from final_project.schemas.ai_prompt_template import (
    AIPromptTemplateCreate,
    AIPromptTemplateUpdate,
    AIPromptTemplateResponse,
    PromptTemplatePurpose
)
from final_project.models.ai_prompt_template import AIPromptTemplateDB
from final_project.services.ai_prompt_template import (
    create_prompt_template,
    update_prompt_template,
    get_template_by_id,
    get_active_templates,
    render_template,
    delete_template
)
from final_project.security import get_current_user
from pydantic import BaseModel

router = APIRouter(prefix="/ai-prompt-templates", tags=["ai-prompt-templates"])

# Response model for rendering prompt
class RenderedPromptResponse(BaseModel):
    template_id: int
    template_name: str
    rendered_text: str

@router.post("/", response_model=AIPromptTemplateResponse, status_code=201)
def create_template(
    template: AIPromptTemplateCreate,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """Create a new AI prompt template"""
    # Only superusers can perform this action
    if not current_user.get("is_superuser", False):
        raise HTTPException(status_code=403, detail="Only superusers can perform this action")
    
    # Assign the creator if not provided
    if not template.created_by:
        template.created_by = current_user["user_id"]
    
    return create_prompt_template(db=db, template_data=template)

@router.get("/", response_model=List[AIPromptTemplateResponse])
def list_templates(
    purpose: Optional[str] = Query(None, description="Filter by purpose"),
    active_only: bool = Query(True, description="Only return active templates"),
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """Get all AI prompt templates, optionally filtered by purpose"""
    # Validate purpose
    if purpose and purpose not in [p.value for p in PromptTemplatePurpose]:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid purpose. Must be one of: {', '.join([p.value for p in PromptTemplatePurpose])}"
        )
    
    # Use service layer for both active and all templates
    return get_active_templates(db=db, purpose=purpose, active_only=active_only)

@router.get("/{template_id}", response_model=AIPromptTemplateResponse)
def get_template(
    template_id: int,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """Get a specific AI prompt template by ID"""
    template = get_template_by_id(db=db, template_id=template_id)
    if not template:
        raise HTTPException(status_code=404, detail="Template not found")
    return template

@router.put("/{template_id}", response_model=AIPromptTemplateResponse)
def update_template(
    template_id: int,
    template: AIPromptTemplateUpdate,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """Update an AI prompt template"""
    # Only superusers can perform this action
    if not current_user.get("is_superuser", False):
        raise HTTPException(status_code=403, detail="Only superusers can perform this action")
    
    updated_template = update_prompt_template(db=db, template_id=template_id, template_data=template)
    if not updated_template:
        raise HTTPException(status_code=404, detail="Template not found")
    return updated_template

@router.delete("/{template_id}")
def delete_prompt_template(
    template_id: int,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """Delete an AI prompt template"""
    # Only superusers can perform this action
    if not current_user.get("is_superuser", False):
        raise HTTPException(status_code=403, detail="Only superusers can perform this action")
    
    success = delete_template(db=db, template_id=template_id)
    if not success:
        raise HTTPException(status_code=404, detail="Template not found")
    return {"message": "Template successfully deleted"}

@router.post("/render", response_model=RenderedPromptResponse)
def render_prompt_template(
    template_id: int,
    parameters: Dict[str, Any],
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_user)
):
    """Render an AI prompt template with the provided parameters"""
    template = get_template_by_id(db=db, template_id=template_id)
    if not template:
        raise HTTPException(status_code=404, detail="Template not found")
    
    rendered_text = render_template(template_text=template.template_text, parameters=parameters)
    return RenderedPromptResponse(
        template_id=template.template_id,
        template_name=template.name,
        rendered_text=rendered_text
    )
