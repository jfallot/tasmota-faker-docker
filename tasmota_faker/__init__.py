from os import path

import jinja2

device_name = "test-device"
firmware_version = "13.0.0.1(tasmota)"


class NoTemplateException(Exception):
    pass


def _load_template(name: str) -> str:
    template_path = f"templates/{name}.json.jinja"

    if not path.exists(template_path):
        raise NoTemplateException(f"Template with the name '{name}' not found!")

    with open(template_path) as f:
        return f.read()


def status_template(name: str, host_name: str, instance: str) -> str:
    template_content = _load_template(name)
    environment = jinja2.Environment()
    template = environment.from_string(template_content)
    return template.render(
        device_name=f"{device_name}-{instance}",
        firmware_version=firmware_version,
        ip_address=host_name,
    )
