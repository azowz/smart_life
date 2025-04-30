from sqlalchemy import Column, Integer, Text, Boolean, DateTime, CheckConstraint, ForeignKey, Index
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from final_project.db import Base

# SQLAlchemy model for storing AI feedback from users
class AIFeedbackDB(Base):
    __tablename__ = "ai_feedback"

    feedback_id = Column(Integer, primary_key=True, autoincrement=True)  # Primary key for feedback
    interaction_id = Column(Integer, ForeignKey("ai_interaction.interaction_id"), nullable=False)  # Foreign key to AI interaction
    user_id = Column(Integer, ForeignKey("users.user_id"), nullable=False)  # Foreign key to user providing feedback
    rating = Column(Integer)  # Rating from 1 to 5
    feedback_text = Column(Text)  # Optional feedback text
    created_at = Column(DateTime, server_default=func.now())  # Timestamp when feedback was created
    is_used_for_improvement = Column(Boolean, default=False)  # Flag to indicate if feedback was used for AI improvement

    # Constraints and indexes for performance and data integrity
    __table_args__ = (
        CheckConstraint("rating >= 1 AND rating <= 5", name="check_rating_range"),  # Ensure rating is between 1 and 5
        Index("idx_ai_feedback_interaction_id", "interaction_id"),  # Index on interaction_id
        Index("idx_ai_feedback_user_id", "user_id"),  # Index on user_id
        Index("idx_ai_feedback_rating", "rating"),  # Index on rating
        Index("idx_ai_feedback_is_used_for_improvement", "is_used_for_improvement"),  # Index on is_used_for_improvement
    )

    # Define relationships
    interaction = relationship("AIInteractionDB", backref="feedback")  # Relationship with AIInteractionDB
    user = relationship("UserDB", backref="ai_feedback")  # Relationship with UserDB
