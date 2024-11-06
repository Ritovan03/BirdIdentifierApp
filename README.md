# Bird Identifier App

A Flutter application that can identify bird species from audio recordings and uploaded MP3 files. The app uses a machine learning model through a Flask backend to classify bird sounds.

# Model Description

This project involves bird sound classification using audio features extracted from audio files. The audio files were downloaded from a link, and feature extraction was done using `librosa` and other libraries. The main focus was on extracting MFCC (Mel-frequency cepstral coefficients) and training a Decision Tree model for classification.

## Project Overview

The goal of this project is to classify bird species based on audio recordings. The workflow involves loading audio files, extracting features using `librosa`, and then using these features to train a Decision Tree model. The features used for training include MFCCs, which are commonly used for audio processing and classification tasks.

## Features
- Record bird sounds directly from the app
- Upload existing MP3 files
- Play/pause audio recordings
- Classify bird species using ML model
- Save classifications for later reference
- View history of identified birds

## Librarie Used
- Librosa (for audio processing)
- NumPy (for numerical operations)
- Scikit-learn (for machine learning, especially the Decision Tree classifier)
- Pandas (for data manipulation)

  ## Dataset
  <li>https://www.kaggle.com/c/birdclef-2022<li/>
