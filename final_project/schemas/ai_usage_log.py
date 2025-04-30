from pydantic import BaseModel, validator
from typing import Optional, Dict, Any, List
from datetime import date

# ✅ Model for creating AI usage logs
class AIUsageLogCreate(BaseModel):
    date: date                                     # The date of the log
    total_requests: int = 0                        # Total number of requests made to the AI
    tokens_consumed: int = 0                       # Total number of tokens consumed
    success_rate: float = 0.00                     # Success rate (percentage) of AI responses
    average_response_time: int = 0                 # Average response time in milliseconds
    cost: float = 0.00                             # Total cost of AI usage
    error_count: int = 0                           # Number of errors occurred
    error_details: Optional[List[Dict[str, Any]]] = None  # Optional list of error details

    # ✅ Validate that success_rate is between 0 and 100
    @validator('success_rate')
    def validate_success_rate(cls, v):
        if v < 0 or v > 100:
            raise ValueError('Success rate must be between 0 and 100')
        return v

    # ✅ Validate that numerical fields are non-negative
    @validator('average_response_time', 'total_requests', 'tokens_consumed', 'error_count')
    def validate_non_negative(cls, v, values, **kwargs):
        if v < 0:
            field_name = kwargs['field'].name
            raise ValueError(f'{field_name} cannot be negative')
        return v

    # ✅ Validate that cost is non-negative
    @validator('cost')
    def validate_cost(cls, v):
        if v < 0:
            raise ValueError('Cost cannot be negative')
        return v

# ✅ Model for AI usage log response
class AIUsageLogResponse(BaseModel):
    log_id: int                                    # Unique ID of the log entry
    date: date                                     # Date of the log entry
    total_requests: int                            # Total number of requests
    tokens_consumed: int                           # Total tokens used
    success_rate: float                            # Success rate percentage
    average_response_time: int                     # Average response time
    cost: float                                    # Total cost
    error_count: int                               # Number of errors
    error_details: Optional[List[Dict[str, Any]]] = None  # Error details (optional)

    # ✅ Configure Pydantic to work with ORM (SQLAlchemy) models
    model_config = {"from_attributes": True}  # Compatible with Pydantic v2
