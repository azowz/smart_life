from fastapi import APIRouter

# Create main router instance
main_router = APIRouter()

# Import all sub-routers
from final_project.router.content import router as content_router
from final_project.router.profile import router as profile_router
from final_project.router.user import router as user_router
from final_project.router.task import router as task_router
from final_project.router.habit import router as habit_router
from final_project.router.category import router as category_router
from final_project.router.task_category import router as task_category_router
from final_project.router.habit_category import router as habit_category_router
from final_project.router.habit_log import router as habit_log_router
from final_project.router.chat_message import router as chat_message_router
from final_project.router.configuration import router as configuration_router
from final_project.router.ai_interaction import router as ai_interaction_router
from final_project.router.ai_feedback import router as ai_feedback_router
from final_project.router.ai_prompt_template import router as ai_prompt_template_router
from final_project.router.ai_training_text import router as ai_training_text_router
from final_project.router.ai_usage_log import router as ai_usage_log_router
from final_project.router.bulk_notification import router as bulk_notification_router
from final_project.router.default_habit import router as default_habit_router
from final_project.router.notification import router as notification_router
from final_project.router.user_settings import router as user_settings_router
from final_project.router.system_setting import router as system_setting_router
from final_project.router.system_statistics import router as system_statistics_router
from final_project.router.user_activity import router as user_activity_router
from final_project.router.user_default_habit import router as user_default_habit_router
from final_project.router.security import router as security_router

# Core application features
main_router.include_router(user_router)
main_router.include_router(task_router)
main_router.include_router(habit_router)
main_router.include_router(category_router)
main_router.include_router(task_category_router)
main_router.include_router(habit_category_router)
main_router.include_router(habit_log_router)

# Communication features
main_router.include_router(chat_message_router)
main_router.include_router(notification_router)
main_router.include_router(bulk_notification_router)

# AI-related features
main_router.include_router(ai_feedback_router)
main_router.include_router(ai_interaction_router)
main_router.include_router(ai_prompt_template_router)
main_router.include_router(ai_training_text_router)
main_router.include_router(ai_usage_log_router)

# System & Admin features
main_router.include_router(configuration_router)
main_router.include_router(system_setting_router)
main_router.include_router(system_statistics_router)

# User-related features
main_router.include_router(profile_router)
main_router.include_router(user_settings_router)
main_router.include_router(user_activity_router)
main_router.include_router(user_default_habit_router)

# Security router
main_router.include_router(security_router)

# Content
main_router.include_router(content_router)

# Default habits
main_router.include_router(default_habit_router)

# Root endpoint for health check
@main_router.get("/")
async def index():
    return {"message": "Hello World!"}