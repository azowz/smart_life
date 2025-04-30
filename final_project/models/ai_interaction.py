from sqlalchemy import Column, Integer, String, Text, Boolean, DateTime, CheckConstraint, ForeignKey, Index
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from enum import Enum
from final_project.db import Base

# Enum for interaction types
class InteractionType(str, Enum):
    CHAT = "chat"
    SUGGESTION = "suggestion"
    ANALYSIS = "analysis"

# SQLAlchemy model for AI interactions
class AIInteractionDB(Base):
    __tablename__ = "ai_interaction"

    interaction_id = Column(Integer, primary_key=True, autoincrement=True)  # Primary key
    user_id = Column(Integer, ForeignKey("users.user_id"), nullable=False)  # Foreign key to UserDB
    prompt = Column(Text, nullable=False)  # AI prompt (input from user)
    response = Column(Text)  # AI response (output)
    template_id = Column(Integer, ForeignKey("ai_prompt_template.template_id"))  # Foreign key to AIPromptTemplateDB
    interaction_type = Column(String(50))  # Type of interaction (chat, suggestion, analysis)
    created_at = Column(DateTime, server_default=func.now())  # Timestamp of interaction creation
    processing_time = Column(Integer)  # Processing time in milliseconds
    tokens_used = Column(Integer)  # Number of tokens used in the interaction
    was_successful = Column(Boolean, default=True)  # Whether the interaction was successful
    #interaction_type = Column(SQLEnum(InteractionType), nullable=False)

    __table_args__ = (
        CheckConstraint("interaction_type IN ('chat', 'suggestion', 'analysis')", name="check_interaction_type"),  # Valid interaction types
        Index("idx_ai_interaction_user_id", "user_id"),  # Index on user_id
        Index("idx_ai_interaction_template_id", "template_id"),  # Index on template_id
        Index("idx_ai_interaction_interaction_type", "interaction_type"),  # Index on interaction_type
        Index("idx_ai_interaction_created_at", "created_at"),  # Index on created_at
    )

    # Relationships
    user = relationship("UserDB", back_populates="ai_interactions")  # Relationship with UserDB
    template = relationship("AIPromptTemplateDB", back_populates="interactions")  # Relationship with AIPromptTemplateDB
    prompt_template = relationship("AIPromptTemplateDB", back_populates="interactions")


