import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.pipeline import Pipeline
from xgboost import XGBClassifier
from sklearn.metrics import classification_report, accuracy_score
import pickle
import re
from pyswip import Prolog


# Function to call Prolog and get MBTI type
def get_mbti_from_prolog(responses):
    prolog = Prolog()
    prolog.consult("C:/Users/nlpcl/PycharmProjects/combine/Prolog/mbti_type_inference_2.pl")  # Path to your Prolog script

    # Construct query with responses
    query = "run_mbti_test({})".format(responses)
    result = list(prolog.query(query))

    if result:
        return result[0]['MBTI_Type']
    return None


# Function to predict specific MBTI dimensions using ML model
def predict_mbti_dimension_with_ml(text, dimension):
    # Load the pre-trained model for the specific dimension
    model_filename = f'model_{dimension}.pkl'
    with open(model_filename, 'rb') as file:
        model = pickle.load(file)

    # Predict using the model
    prediction = model.predict([text])
    return prediction[0]


def main():
    # Example responses
    responses = [
        ('introvert_extrovert', 'I think social gatherings'),
        ('sensing_intuition', 'I facts on facts and details'),
        ('thinking_feeling', 'I prioritize logic'),
        ('judging_perceiving', 'I like planned routine')
    ]

    # Convert responses to Prolog format
    prolog_responses = ','.join([f"{dim}-['{ans}']" for dim, ans in responses])

    # Get MBTI type from Prolog
    mbti_type = get_mbti_from_prolog(prolog_responses)

    # Split the MBTI type into dimensions
    mbti_dimensions = ['E_I', 'N_S', 'T_F', 'P_J']
    predicted_dimensions = list(mbti_type)

    # Predict unknown dimensions using ML
    for i, dimension in enumerate(predicted_dimensions):
        if dimension == 'unknown':
            # Get the corresponding answer for the dimension
            answer = responses[i][1]
            predicted_dimension = predict_mbti_dimension_with_ml(answer, mbti_dimensions[i])
            predicted_dimensions[i] = predicted_dimension

    # Combine the predicted dimensions
    final_mbti_type = ''.join(predicted_dimensions)
    print(f"Final MBTI Type: {final_mbti_type}")


if __name__ == "__main__":
    main()
