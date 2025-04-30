from sqlalchemy import Column, Integer, Date, Numeric, Index, UniqueConstraint
from sqlalchemy.dialects.postgresql import JSON
from final_project.db import Base

# SQLAlchemy model for logging daily AI usage statistics
class AIUsageLogDB(Base):
    __tablename__ = "ai_usage_log"

    log_id = Column(Integer, primary_key=True, autoincrement=True)  # Primary key
    date = Column(Date, nullable=False)  # Date of the log (unique per day)
    total_requests = Column(Integer, nullable=False, default=0)  # Total AI requests for the day
    tokens_consumed = Column(Integer, nullable=False, default=0)  # Total tokens consumed
    success_rate = Column(Numeric(5, 2), nullable=False, default=0.00)  # Success rate (percentage)
    average_response_time = Column(Integer, nullable=False, default=0)  # Average response time (milliseconds)
    cost = Column(Numeric(10, 2), nullable=False, default=0.00)  # Total cost
    error_count = Column(Integer, nullable=False, default=0)  # Total number of errors
    error_details = Column(JSON)  # JSON field for error breakdown (e.g., {"timeout": 3, "500_error": 2})

    __table_args__ = (
        UniqueConstraint("date", name="unique_date_log"),  # Ensure one log per day
        Index("idx_ai_usage_log_date", "date"),  # Index on date for faster queries
    )
