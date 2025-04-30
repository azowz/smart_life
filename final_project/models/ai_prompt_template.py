from datetime import datetime
from enum import Enum

from sqlalchemy import Column, Integer, String, Text, Boolean, DateTime, CheckConstraint, ForeignKey, Index, event
from sqlalchemy.dialects.postgresql import JSON
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from final_project.db import Base
from final_project.models.user import UserDB

# Enum for prompt template purposes
# class PromptTemplatePurpose(str, Enum):
#     TASK_SUGGESTION = "task_suggestion"
#     HABIT_RECOMMENDATION = "habit_recommendation"
#     CHAT_RESPONSE = "chat_response"

class AIPromptTemplateDB(Base):
    __tablename__ = "ai_prompt_template"

    template_id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(100), nullable=False)
    purpose = Column(String(50), nullable=False)
    template_text = Column(Text, nullable=False)
    parameters = Column(JSON, nullable=True)

    # Reference to the user who created this template
    created_by_user_id = Column(Integer, ForeignKey("users.user_id"), nullable=False)

    created_at = Column(DateTime, server_default=func.now(), nullable=False)
    last_updated = Column(DateTime, server_default=func.now(), nullable=False)
    is_active = Column(Boolean, default=True, nullable=False)

    __table_args__ = (
        CheckConstraint(
            "purpose IN ('task_suggestion', 'habit_recommendation', 'chat_response')",
            name="check_ai_prompt_template_purpose"
        ),
        Index("idx_ai_prompt_template_purpose", "purpose"),
        Index("idx_ai_prompt_template_is_active", "is_active"),
    )

        # Relationship to UserDB
    user = relationship(
        UserDB,
        back_populates="ai_prompt_templates"
    )

    # Relationship to AI interactions
    interactions = relationship(
        "AIInteractionDB",
        back_populates="prompt_template",
        cascade="all, delete-orphan"
    )

# Event listener to update 'last_updated' timestamp before updates
@event.listens_for(AIPromptTemplateDB, 'before_update')
def _update_last_updated(mapper, connection, target):
    target.last_updated = datetime.utcnow()
