# Import all services here to make them available when importing the services package
from final_project.services.category import (
    create_category, 
    update_category, 
    get_category, 
    get_categories, 
    get_category_with_subcategories, 
    delete_category
)
from final_project.services.task_category import (
    add_category_to_task,
    remove_category_from_task,
    get_categories_for_task,
    get_tasks_by_category
)
from final_project.services.habit_category import (
    add_category_to_habit,
    remove_category_from_habit,
    get_categories_for_habit,
    get_habits_by_category
)
from final_project.services.chat_message import (
    create_message,
    update_message,
    get_message,
    delete_message,
    get_user_messages,
    get_messages_by_entity
)
from final_project.services.configuration import (
    create_configuration,
    update_configuration,
    get_configuration,
    get_all_configurations,
    get_active_configuration,
    delete_configuration
)
from final_project.services.ai_prompt_template import (
    create_prompt_template,
    update_prompt_template,
    get_template_by_id,
    get_active_templates,
    render_template,
    delete_template
)
from final_project.services.ai_training_text import (
    create_training_text,
    update_training_text,
    get_training_text,
    get_training_texts,
    increment_usage_count,
    delete_training_text
)
# You can add more service imports here as you create them

