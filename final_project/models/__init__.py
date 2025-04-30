# final_project/models/__init__.py

# Base models
from final_project.db import Base

# User-related models (foundation models first)
from final_project.models.user import UserDB

# User settings and activity
from final_project.models.user_settings import UserSettingsDB
from final_project.models.user_activity import UserActivityDB
from final_project.models.user_default_habit import UserDefaultHabitDB

# Category (foundational model needed by related models)
from final_project.models.category import CategoryDB

# Task-related models
from final_project.models.task import TaskDB
from final_project.models.task_category import TaskCategoryDB

# Habit-related models
from final_project.models.habit import HabitDB
from final_project.models.habit_category import HabitCategoryDB
from final_project.models.habit_log import HabitLogDB

# Default habits
from final_project.models.default_habit import DefaultHabitDB

# AI-related models
from final_project.models.ai_interaction import AIInteractionDB
from final_project.models.ai_feedback import AIFeedbackDB
from final_project.models.ai_prompt_template import AIPromptTemplateDB
from final_project.models.ai_training_text import AITrainingTextDB
from final_project.models.ai_usage_log import AIUsageLogDB

# Notifications
from final_project.models.notification import NotificationDB
from final_project.models.bulk_notification import BulkNotificationDB

# Configurations & System
from final_project.models.configuration import ConfigurationDB
from final_project.models.system_setting import SystemSettingDB
from final_project.models.system_statistics import SystemStatisticsDB

# Content model (import after UserDB)
from final_project.models.content import ContentDB