from fastapi import FastAPI
import os

api = FastAPI()


def load_animals():
    env = os.environ.get("ANIMALS")
    if env is None:
        raise ValueError("Environment variable 'ANIMALS' is not set.")
    return env.split(",")


animal_tuples = load_animals()
animals = []


@api.get("/zoo")
def list_animals():
    animal_list = []
    for animal_tuple in animal_tuples:
        parts = animal_tuple.split("=")
        animal = {
            "type": parts[0],
            "name": parts[1]
        }
        animal_list.append(animal)
    return {"animals": animal_list}
