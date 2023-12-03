import re

from pyswip import Prolog
import pandas as pd
from sklearn.pipeline import Pipeline
from sklearn.feature_extraction.text import TfidfVectorizer
from xgboost import XGBClassifier
import pickle

questions = ['Do you prefer solitary activities or social gatherings?', 'Do you pay more attention to facts and details or to ideas and concepts?', 'When making decisions, do you prioritize logic or personal values?', 'Do you prefer to have a planned routine or to go with the flow?']


def run_prolog_mbti_test():
    prolog = Prolog()
    prolog.consult('C:/Users/nlpcl/PycharmProjects/combine/Prolog/mbti_prolog.pl')
    for result in prolog.query("run_mbti_test(MBTI_Type)"):
        mbti_type = result['MBTI_Type']
        return mbti_type
    return None




def predict_mbti_ml(user_input, type):
    predicted_dimensions = []
    # Define paths to your trained models
    model_paths = {
        'EI': 'model_E_I.pkl',
        'NS': 'model_N_S.pkl',
        'TF': 'model_T_F.pkl',
        'PJ': 'model_P_J.pkl'
    }

    # Load and use each model to predict its respective dimension
    with open(model_paths[type], 'rb') as file:
        model = pickle.load(file)
    #predicted_dimension =
    user_input = user_input.encode('utf-8', 'ignore').decode('utf-8')
    temp = model.predict([user_input])[0]
    #preprocess to get the result

    if temp == 0:
        predicted_dimension = type[0]
    else:
        predicted_dimension = type[1]

    return predicted_dimension



def main():
    # Run the Prolog MBTI test
    mbti_type_prolog = run_prolog_mbti_test()
    print(mbti_type_prolog)
    # Check if Prolog returns an incomplete type (e.g., 'Eunknownunknownunknown')
    mbti_type_prolog = mbti_type_prolog.replace("unknown", "")
    EI = re.match(r'[EI]', mbti_type_prolog)
    # replace [EI] with E if it's incomplete using re
    if EI:
        EI = EI.group()
        mbti_type_prolog = re.sub(r'[EI]', '', mbti_type_prolog)

    NS = re.match(r'[NS]', mbti_type_prolog)

    if NS:
        NS = NS.group()
        mbti_type_prolog = re.sub(r'[NS]', '', mbti_type_prolog)

    TF = re.match(r'[TF]', mbti_type_prolog)

    if TF:
        TF = TF.group()
        mbti_type_prolog = re.sub(r'[TF]', '', mbti_type_prolog)

    PJ = re.match(r'[PJ]', mbti_type_prolog)
    if PJ:
        PJ = PJ.group()
        mbti_type_prolog = re.sub(r'[PJ]', '', mbti_type_prolog)

    # Run the ML MBTI test
    print([EI, NS, TF, PJ])
    result = ""
    for i, type in enumerate([EI, NS, TF, PJ]):
        if not type:
            print(questions[i])
            user_input = input("Enter your responses: ")
            temp = ['EI', 'NS', 'TF', 'PJ']
            temp = predict_mbti_ml(user_input, temp[i])
            result += str(temp)
            #print(mbti_type_ml)
        else:
            result += str(type)
    print("result:", result)




if __name__ == '__main__':
    main()
