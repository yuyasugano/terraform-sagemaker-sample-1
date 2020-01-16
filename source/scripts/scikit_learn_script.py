'''
DERIVED FROM:https://github.com/aws/sagemaker-python-sdk/blob/master/src/sagemaker/sklearn/README.rst
Preparing the Scikit-learn training script
Your Scikit-learn training script must be a Python 2.7 or 3.5 compatible source file.
The training script is very similar to a training script you might run outside of SageMaker, 
but you can access useful properties about the training environment through various environment variables, 
such as
- SM_MODEL_DIR: 
        A string representing the path to the directory to write model artifacts to. 
        These artifacts are uploaded to S3 for model hosting.
- SM_OUTPUT_DATA_DIR: 
        A string representing the filesystem path to write output artifacts to. 
        Output artifacts may include checkpoints, graphs, and other files to save, 
        not including model artifacts. These artifacts are compressed and uploaded 
        to S3 to the same S3 prefix as the model artifacts.
        Supposing two input channels, 'train' and 'test', 
        were used in the call to the Scikit-learn estimator's fit() method, 
        the following will be set, following the format "SM_CHANNEL_[channel_name]":
- SM_CHANNEL_TRAIN: 
        A string representing the path to the directory containing data in the 'train' channel
- SM_CHANNEL_TEST: 
        Same as above, but for the 'test' channel.
        A typical training script loads data from the input channels, 
        configures training with hyperparameters, trains a model, 
        and saves a model to model_dir so that it can be hosted later. 
        Hyperparameters are passed to your script as arguments and can 
        be retrieved with an argparse.ArgumentParser instance. 
        For example, a training script might start with the following:
Because the SageMaker imports your training script, 
you should put your training code in a main guard (if __name__=='__main__':) 
if you are using the same script to host your model, 
so that SageMaker does not inadvertently run your training code at the wrong point in execution.
For more on training environment variables, please visit https://github.com/aws/sagemaker-containers.
'''

import argparse
import pandas as pd
import os

# GradientBoosting Regressor
from sklearn.ensemble import GradientBoostingRegressor
from sklearn.externals import joblib

# Pipeline and StandardScaler
from sklearn.preprocessing import StandardScaler
from sklearn.pipeline import Pipeline

if __name__ == '__main__':
    parser = argparse.ArgumentParser()

    # Hyperparameters are described here. In this simple example we are just including one hyperparameter.
    parser.add_argument('--learning_rate', type=float, default=0.1)
    parser.add_argument('--n_estimators', type=int, default=100)
    
    # Sagemaker specific arguments. Defaults are set in the environment variables.
    parser.add_argument('--output-data-dir', type=str, default=os.environ['SM_OUTPUT_DATA_DIR'])
    parser.add_argument('--model-dir', type=str, default=os.environ['SM_MODEL_DIR'])
    parser.add_argument('--train', type=str, default=os.environ['SM_CHANNEL_TRAIN'])

    args = parser.parse_args()
    
    # Take the set of files and read them all into a single pandas dataframe
    input_files = [os.path.join(args.train, file) for file in os.listdir(args.train) ]
    if len(input_files) == 0:
        raise ValueError(('There are no files in {}.\n' +
                          'This usually indicates that the channel ({}) was incorrectly specified,\n' +
                          'the data specification in S3 was incorrectly specified or the role specified\n' +
                          'does not have permission to access the data.').format(args.train, "train"))
    raw_data = [pd.read_csv(file, header=None, engine="python") for file in input_files]
    train_data = pd.concat(raw_data)

    # labels are in the last column, train data are in the latter columns
    train_y = train_data.iloc[:,-1]
    train_X = train_data.iloc[:,0:-1]

    # Here we support a single hyperparameter
    learning_rate = args.learning_rate
    n_estimators = args.n_estimators

    # Now use scikit-learn's decision tree classifier to train the model.
    clf = GradientBoostingRegressor(learning_rate=learning_rate, n_estimators=n_estimators)
    clf = clf.fit(train_X, train_y)
    print(clf)

    # The trained classifier, and save the coefficients
    joblib.dump(clf, os.path.join(args.model_dir, "model.joblib"))

def model_fn(model_dir):
    """Deserialized and return fitted model

    Note that this should have the same name as the serialized model in the main method
    """
    clf = joblib.load(os.path.join(model_dir, "model.joblib"))
    return clf
