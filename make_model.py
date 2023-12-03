import pandas as pd
from sklearn.ensemble import BaggingClassifier
from sklearn.model_selection import train_test_split
from sklearn.feature_extraction.text import TfidfVectorizer
from xgboost import XGBClassifier
from sklearn.pipeline import Pipeline
from sklearn.metrics import classification_report, accuracy_score
import pickle
import spacy
import re
from tqdm import tqdm
from sklearn.preprocessing import LabelEncoder

nlp = spacy.load('en_core_web_sm')

def split_and_group_posts(df, post_col='posts', type_col='type', chunk_size=10):
    # Split the posts and assign types
    split_posts = df[post_col].str.split('\\|\\|\\|').explode().reset_index(drop=True)
    #split_types = df[type_col].repeat(split_posts.groupby(level=0).size()).reset_index(drop=True)
    split_types = df[type_col].repeat(df[post_col].str.split('\\|\\|\\|').apply(len)).reset_index(drop=True)
    # Create a new DataFrame with split posts and their types
    new_df = pd.DataFrame({post_col: split_posts, type_col: split_types})

    # Group posts into chunks
    grouped_posts = new_df.groupby(new_df.index // chunk_size).agg({
        post_col: ' '.join,
        type_col: 'first'
    }).reset_index(drop=True)

    return grouped_posts

def clean_text(text):
    text = text.lower()
    text = re.sub(r'http\S+|www\.\S+', 'url', text)
    text = re.sub(r'[^\w\s]', '', text)
    text = re.sub(r'\d+', '', text)
    return text

def clean_texts(texts):
    cleaned_texts = []
    for doc in nlp.pipe(texts, batch_size=50, n_process=-1):
        cleaned_text = ' '.join([token.lemma_ for token in doc if not token.is_stop and token.is_alpha])
        cleaned_texts.append(cleaned_text)
    return cleaned_texts

def main():

    #df = pd.read_csv('/Users/hwangyun/PycharmProjects/MBTI/mbti_1.csv')
    # df['type'] = df['type'].astype('category')
    # #data_dir = '/Users/hwangyun/PycharmProjects/MBTI/mbti_1.csv'
    # # Split and chunk the posts
    #df_for_pos = split_and_group_posts(df)
    # df_final['cleaned_text'] = clean_texts(df_final['posts'].apply(clean_text))
    # df_final.to_csv('mbti_preprocessed.csv', index=False)
    df_final = pd.read_csv('mbti_preprocessed.csv')
    le = LabelEncoder()

    # Apply Label Encoding to each dichotomy
    df_final['E_I'] = le.fit_transform(df_final['type'].apply(lambda x: 'E' if 'E' in x else 'I'))
    df_final['N_S'] = le.fit_transform(df_final['type'].apply(lambda x: 'N' if 'N' in x else 'S'))
    df_final['T_F'] = le.fit_transform(df_final['type'].apply(lambda x: 'T' if 'T' in x else 'F'))
    df_final['P_J'] = le.fit_transform(df_final['type'].apply(lambda x: 'P' if 'P' in x else 'J'))

    X = df_final['cleaned_text']
    dichotomies = ['E_I', 'N_S', 'T_F', 'P_J']

    for dichotomy in dichotomies:
        y = df_final[dichotomy]
        X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

        text_clf = Pipeline([
            ('tfidf', TfidfVectorizer(ngram_range=(1, 2))),
            #('clf', BaggingClassifier(n_estimators=10, random_state=42, use_label_encoder=False, eval_metric='logloss', n_jobs=-1))
            ('clf', XGBClassifier(n_estimators=200, random_state=42, n_jobs=-1))
        ])

        text_clf.fit(X_train, y_train)

        filename = f'model_{dichotomy}.pkl'
        pickle.dump(text_clf, open(filename, 'wb'))

        predictions = text_clf.predict(X_test)

        print(f"Classification report for {dichotomy}:")
        print(classification_report(y_test, predictions))
        print(f"Overall accuracy of the model for {dichotomy}: {round(accuracy_score(y_test, predictions), 2)}")


if __name__ == '__main__':
    main()
