from sqlalchemy import Column, Integer, String, Boolean, DateTime, CheckConstraint
from sqlalchemy.dialects.postgresql import JSON
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from final_project.db import Base

# Model for admin users
class AdminDB(Base):
    __tablename__ = "admins"

    admin_id = Column(Integer, primary_key=True, autoincrement=True)  # Admin ID (Primary Key)
    username = Column(String(50), unique=True, nullable=False)  # Unique username
    email = Column(String(100), unique=True, nullable=False)  # Unique email
    password_hash = Column(String(255), nullable=False)  # Hashed password
    full_name = Column(String(100), nullable=False)  # Admin's full name
    permissions = Column(JSON)  # Admin permissions (JSON format)
    phone_number = Column(String(20))  # Admin's phone number
    preferred_2fa_method = Column(String(20))  # Preferred method for 2FA
    security_questions = Column(JSON)  # Security questions for 2FA (JSON format)
    created_at = Column(DateTime, server_default=func.now())  # Account creation timestamp
    last_login = Column(DateTime)  # Last login timestamp
    is_active = Column(Boolean, default=True)  # Is the admin account active?

    __table_args__ = (
        CheckConstraint(
            "preferred_2fa_method IN ('sms', 'email', 'app', 'security_questions')",  # Ensure valid 2FA methods
            name="check_preferred_2fa_method",
        ),
    )

    # Relationships
    categories_created = relationship("CategoryDB", back_populates="creator_admin")  # Categories created by admin
    tasks_created = relationship("TaskDB", back_populates="creator_admin")  # Tasks created by admin
    dashboards = relationship("AdminDashboardDB", back_populates="admin")  # Dashboards associated with admin
    statistics = relationship("AdminStatisticsDB", back_populates="admin")  # Statistics associated with admin
    settings = relationship("SystemSettingDB", back_populates="admin", cascade="all, delete-orphan")  # Relationship with SystemSettingDB

# Import AdminStatisticsDB at the end to avoid circular imports
from final_project.models.admin.adminstatistics import AdminStatisticsDB
