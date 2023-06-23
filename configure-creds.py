import yaml

def generate_menu(infrastructure_providers):
    menu = "Infrastructure Providers:\n"
    for index, provider in enumerate(infrastructure_providers):
        menu += f"{index + 1}. {provider['name']}\n"
    menu += "0. Exit\n"
    return menu

def edit_provider(provider):
    print(f"Editing {provider['name']}:")
    for key, value in provider.items():
        if isinstance(value, dict):
            print(f"{key.capitalize()}:")
            for sub_key, sub_value in value.items():
                new_value = input(f"  {sub_key}: ({sub_value}) ")
                if new_value:
                    provider[key][sub_key] = new_value
        else:
            new_value = input(f"{key.capitalize()}: ({value}) ")
            if new_value:
                provider[key] = new_value
    print("Provider edited successfully!")

def save_changes(data, file_path):
    with open(file_path, 'w') as file:
        yaml.dump(data, file)
    print("Changes saved successfully!")

def generate_new_file(file_path, new_file_path, infrastructure_providers):
    with open(file_path, 'r') as file:
        data = yaml.safe_load(file)
        data['infrastructure_providers'] = infrastructure_providers
        with open(new_file_path, 'w') as new_file:
            yaml.dump(data, new_file)
        print(f"New file '{new_file_path}' generated successfully!")

file_path = 'example_vars/credentials-infrastructure.yaml'
new_file_path = 'vars/credentials-infrastructure.yaml'

with open(file_path, 'r') as file:
    data = yaml.safe_load(file)
    infrastructure_providers = data['infrastructure_providers']
    menu = generate_menu(infrastructure_providers)

    while True:
        print(menu)
        choice = input("Enter the number of the provider to edit (0 to exit): ")
        if choice == '0':
            break
        try:
            index = int(choice) - 1
            if 0 <= index < len(infrastructure_providers):
                provider = infrastructure_providers[index]
                edit_provider(provider)
                save_changes(data, file_path)
            else:
                print("Invalid choice. Please try again.")
        except ValueError:
            print("Invalid choice. Please enter a number.")

    generate_new_file(file_path, new_file_path, infrastructure_providers)

print("Exiting the program.")
