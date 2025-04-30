from sqlalchemy import Column, Integer, String, Boolean, CheckConstraint, ForeignKey, UniqueConstraint
from sqlalchemy.dialects.postgresql import JSON
from sqlalchemy.orm import relationship
from final_project.db import Base

# SQLAlchemy model for storing user settings
class UserSettingsDB(Base):
    __tablename__ = "user_settings"

    settings_id = Column(Integer, primary_key=True, autoincrement=True)  # Primary key
    user_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False)  # Link to UserDB

    theme = Column(String(10), default="system")  # Theme preference (light, dark, system)
    notification_preferences = Column(JSON, default={})  # Notification preferences as JSON
    language = Column(String(10), default="en")  # Preferred language
    time_zone = Column(String(50), default="UTC")  # Preferred time zone
    ai_assistant_enabled = Column(Boolean, default=True)  # Whether AI assistant is enabled
    timezone = Column(String, default="UTC")  # Duplicate timezone field (optional redundancy)

    # Relationship with UserDB
    user = relationship("UserDB", back_populates="settings")

    __table_args__ = (
        CheckConstraint("theme IN ('light', 'dark', 'system')", name="check_theme"),  # Validates theme values
        UniqueConstraint("user_id", name="idx_user_settings_user_id"),  # Ensures one settings record per user
    )

# In UserDB model:
# settings = relationship("UserSettingsDB", back_populates="user", cascade="all, delete-orphan")