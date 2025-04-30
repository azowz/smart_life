import pytest
from final_project.schemas.task_category import TaskCategory


def test_model_config_from_attributes():
    # Test that from_attributes is set to True in model configuration
    assert TaskCategory.model_config.get("from_attributes") is True

def test_model_config_orm_mode_compatibility():
    # Verify the configuration matches Pydantic v2 ORM mode replacement
    config = TaskCategory.model_config
    assert "from_attributes" in config
    assert config["from_attributes"] is True

def test_model_config_type():
    # Ensure model_config is a dictionary
    assert isinstance(TaskCategory.model_config, dict)
