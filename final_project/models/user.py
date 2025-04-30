from sqlalchemy import Column, Integer, String, Boolean, DateTime, CheckConstraint
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship

from final_project.db import Base

class UserDB(Base):
    __tablename__ = "users"

    # Columns
    user_id = Column(Integer, primary_key=True, autoincrement=True)
    username = Column(String(50), unique=True, nullable=False)
    email = Column(String(100), unique=True, nullable=False)
    password_hash = Column(String(255), nullable=False)
    phone_number = Column(String(20), nullable=True)
    profile_picture = Column(String(255), nullable=True)
    first_name = Column(String(50), nullable=True)
    last_name = Column(String(50), nullable=True)
    gender = Column(String(10), nullable=True)
    is_active = Column(Boolean, default=True, nullable=False)
    superuser = Column(Boolean, default=False, nullable=False)
    created_at = Column(DateTime, server_default=func.now(), nullable=False)
    last_login = Column(DateTime, nullable=True)

    # Constraints
    __table_args__ = (
        CheckConstraint("gender IN ('male','female')", name="check_gender"),
    )

    # Relationships
    settings = relationship("UserSettingsDB", back_populates="user", uselist=False, cascade="all, delete-orphan")
    tasks = relationship("TaskDB", back_populates="user", cascade="all, delete-orphan")
    habits = relationship("HabitDB", back_populates="user", cascade="all, delete-orphan")
    categories_created = relationship("CategoryDB", back_populates="creator_user", cascade="all, delete-orphan")
    activities = relationship("UserActivityDB", back_populates="user", cascade="all, delete-orphan")
    ai_interactions = relationship("AIInteractionDB", back_populates="user", cascade="all, delete-orphan")
    notifications = relationship("NotificationDB", back_populates="user", cascade="all, delete-orphan")
    ai_prompt_templates = relationship("AIPromptTemplateDB", back_populates="user", cascade="all, delete-orphan")
    system_settings = relationship("SystemSettingDB", back_populates="updated_by_user", cascade="save-update, merge, refresh-expire")
    habit_logs = relationship("HabitLogDB", back_populates="user", cascade="all, delete-orphan")
    user_default_habits = relationship("UserDefaultHabitDB", back_populates="user", cascade="all, delete-orphan")
    ai_training_texts = relationship("AITrainingTextDB", back_populates="user", cascade="all, delete-orphan")
    bulk_notifications = relationship("BulkNotificationDB", back_populates="user", cascade="save-update, merge, refresh-expire")
    configurations = relationship("ConfigurationDB", back_populates="user", cascade="save-update, merge, refresh-expire")
    
    # Use string reference for ContentDB to avoid circular import issues
    contents = relationship(
        "ContentDB",
        back_populates="user",
        cascade="all, delete-orphan",
        lazy="selectin"
    )