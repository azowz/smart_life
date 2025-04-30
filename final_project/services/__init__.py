# """
# services/__init__.py

# Centralized imports for all service modules to make them available 
# when importing the services package.

# Organized by functional areas with clear grouping and documentation.
# """

# # ======================
# # Core Functionality Services
# # ======================

# # User Management
# from final_project.services.admin import (
#     create_admin,
#     update_admin,
#     get_admin,
#     get_admins,
#     delete_admin,
# )

# from final_project.services.user import (
#     create_user,
#     update_user,
#     get_user,
#     get_users,
#     delete_user,
#     get_user_by_username,
#     get_user_by_email,
#     get_user_by_phone_number,
# )

# # Category Management
# from final_project.services.category import (
#     create_category,
#     update_category,
#     get_category,
#     get_categories,
#     get_category_with_subcategories,
#     delete_category,
# )

# # Task Management
# from final_project.services.task_category import (
#     add_category_to_task,
#     remove_category_from_task,
#     get_categories_for_task,
# )

# # Habit Management
# from final_project.services.habit import (
#     create_habit,
#     update_habit,
#     get_habit,
#     get_habits,
#     delete_habit,
#     get_habits_by_user_id,
#     get_habits_by_category_id,
# )

# from final_project.services.habit_category import (
#     create_habit_category,
#     update_habit_category,
#     get_habit_category,
#     get_habit_categories,
#     delete_habit_category,
# )

# # ======================
# # Communication Services
# # ======================

# # Chat Services
# from final_project.services.chat_message import (
#     create_chat_message,
#     update_chat_message,
#     get_chat_message,
#     get_chat_messages,
#     delete_chat_message,
#     get_chat_messages_by_user_id,
# )

# # Notification Services
# from final_project.services.notification import (
#     create_notification,
#     update_notification,
#     get_notification,
#     get_notifications,
#     delete_notification,
# )

# from final_project.services.bulk_notification import (
#     create_bulk_notification,
#     update_bulk_notification,
#     get_bulk_notification,
#     get_bulk_notifications,
#     delete_bulk_notification,
# )

# # ======================
# # AI Services
# # ======================

# # AI Core Services
# from final_project.services.ai_service import (
#     create_ai_service,
#     update_ai_service,
#     get_ai_service,
#     get_ai_services,
#     delete_ai_service,
# )

# # AI Interaction Services
# from final_project.services.ai_interaction import (
#     create_ai_interaction,
#     update_ai_interaction,
#     get_ai_interaction,
#     get_ai_interactions,
#     delete_ai_interaction,
#     create_interaction,
#     update_interaction,
#     get_interaction,
#     get_interactions,
#     delete_interaction,
# )

# # AI Feedback Services
# from final_project.services.ai_feedback import (
#     create_ai_feedback,
#     update_ai_feedback,
#     get_ai_feedback,
#     get_ai_feedbacks,
#     delete_ai_feedback,
#     create_feedback,
# )

# # AI Training Services
# from final_project.services.ai_prompt_template import (
#     create_prompt_template,
#     update_prompt_template,
#     get_prompt_template,
#     get_prompt_templates,
#     delete_prompt_template,
#     get_active_templates,
#     get_template_by_id,
# )

# from final_project.services.ai_training_text import (
#     create_training_text,
#     update_training_text,
#     get_training_text,
#     get_training_texts,
#     delete_training_text,
# )

# from final_project.services.ai_usage_log import (
#     create_usage_log,
#     update_usage_log,
#     get_usage_log,
#     get_usage_logs,
#     delete_usage_log,
# )

# # ======================
# # System Services
# # ======================

# # Configuration Services
# from final_project.services.configuration import (
#     create_configuration,
#     update_configuration,
#     get_configuration,
#     get_configurations,
#     delete_configuration,
# )

# # System Settings
# from final_project.services.system_setting import (
#     create_system_setting,
#     update_system_setting,
#     get_system_setting,
#     get_system_settings,
#     delete_system_setting,
# )

# # Statistics Services
# from final_project.services.system_statistics import (
#     create_system_statistics,
#     update_system_statistics,
#     get_system_statistics,
#     get_system_statistics_by_id,
#     delete_system_statistics,
# )

# from final_project.services.user_statistics import (
#     get_user_statistics,
#     get_user_statistics_by_id,
#     delete_user_statistics,
# )

# # Activity Services
# from final_project.services.user_activity import (
#     create_user_activity,
#     update_user_activity,
#     get_user_activity,
#     get_user_activities,
#     delete_user_activity,
# )

# # ======================
# # Admin Dashboard Services
# # ======================

# from final_project.services.admin_dashboard import (
#     get_user_statistics,
#     get_task_statistics,
#     get_habit_statistics,
#     get_system_statistics,
#     get_user_activity_logs,
#     get_system_settings,
#     get_system_statistics_overview,
#     get_user_settings_overview,
#     get_user_activity_overview,
#     get_user_activity_by_date,
# )

# # ======================
# # Default Data Services
# # ======================

# from final_project.services.default_habit import (
#     create_default_habit,
#     update_default_habit,
#     get_default_habit,
#     get_default_habits,
#     delete_default_habit,
# )

# from final_project.services.user_default_habit import (
#     create_user_default_habit,
#     update_user_default_habit,
#     get_user_default_habit,
#     get_user_default_habits,
#     delete_user_default_habit,
# )