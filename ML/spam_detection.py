import numpy as np
import sklearn
from sklearn.model_selection import train_test_split
from sklearn.pipeline import Pipeline
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.naive_bayes import MultinomialNB
from sklearn.svm import LinearSVC
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import classification_report

# Choosing Model

raw_data = open('./smsspamcollection/SMSSpamCollection.txt', 'r')
sms_data = []
for line in raw_data:
    split_line = line.split("\t")
    sms_data.append(split_line)

sms_data = np.array(sms_data)
X = [x.lower() for x in sms_data[:, 1]]
y = sms_data[:, 0]
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=13)

pipeline_1 = Pipeline([('vect', CountVectorizer()),('clf', MultinomialNB())])
pipeline_2 = Pipeline([('vect', CountVectorizer()),('clf', LinearSVC())])
pipeline_3 = Pipeline([('vect', CountVectorizer()),('clf', RandomForestClassifier())])
pipelines = [pipeline_1, pipeline_2, pipeline_3]

for pipeline in pipelines:
    pipeline.fit(X, y)
    y_pred = pipeline.predict(X_test)
    print(classification_report(y_test, y_pred, target_names=["ham", "spam"]))


# Converting Model
import coremltools

vectorizer = CountVectorizer()
vectorized = vectorizer.fit_transform(X)

# Used for vectorizing on iOS side
words = open('words_ordered.txt', 'w')
for feature in vectorizer.get_feature_names():
    words.write(feature.encode('utf-8') + '\n')
words.close()

model = LinearSVC()
model.fit(vectorized, y)

coreml_model = coremltools.converters.sklearn.convert(model, "message", "label")
coreml_model.save('SpamDetector.mlmodel')