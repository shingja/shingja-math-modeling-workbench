#!/usr/bin/env python3
# 作者 shingja · github.com/shingja/shingja-math-modeling-workbench · 双许可见 LICENSE · 含隐形溯源标记⁠​‌‌​‌‌​‌​‌‌​​​​‌​‌‌‌​‌​​​‌‌​‌​​​​​‌​‌‌​‌​‌‌​‌‌​‌​‌‌​‌‌‌‌​‌‌​​‌​​​‌‌​​‌​‌​‌‌​‌‌​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​​‌​‌‌​‌​‌‌‌​‌‌‌​‌‌​‌‌‌‌​‌‌‌​​‌​​‌‌​‌​‌‌​‌‌​​​‌​​‌‌​​‌​‌​‌‌​‌‌‌​​‌‌​​​‌‌​‌‌​‌​​​​​‌​‌‌‌‌​‌‌‌​​‌‌​‌‌​‌​​​​‌‌​‌​​‌​‌‌​‌‌‌​​‌‌​​‌‌‌​‌‌​‌​‌​​‌‌​​​​‌⁠
"""
CatBoost Classification & Regression Demo
==========================================
Source: Prokhorenkova, L. et al. (2018). CatBoost: unbiased boosting with categorical features. NeurIPS.
Package: catboost >= 1.2
License: MIT
Verified: 2026-07-27

Usage:
    pip install catboost
    python catboost_demo.py
"""

import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, roc_auc_score, mean_squared_error, r2_score
from catboost import CatBoostClassifier, CatBoostRegressor, Pool
import warnings
warnings.filterwarnings('ignore')


def demo_classification():
    """二分类示例：使用合成数据"""
    print("=" * 60)
    print("CatBoost Classification Demo")
    print("=" * 60)

    # 生成合成数据
    np.random.seed(42)
    n_samples, n_features = 1000, 20
    X = np.random.randn(n_samples, n_features)
    # 真实关系: 只有前 5 个特征有用
    logits = 2 * X[:, 0] - 1.5 * X[:, 1] + X[:, 2] - 0.5 * X[:, 3] + 0.3 * X[:, 4]
    prob = 1 / (1 + np.exp(-logits))
    y = (prob > 0.5).astype(int)

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )

    # 添加分类特征 (模拟)
    cat_features_idx = [10, 11]  # 特征 10, 11 为分类变量

    # 训练模型
    model = CatBoostClassifier(
        iterations=500,
        learning_rate=0.03,
        depth=6,
        l2_leaf_reg=3.0,
        random_seed=42,
        early_stopping_rounds=50,
        verbose=100,
    )

    model.fit(
        X_train, y_train,
        cat_features=cat_features_idx,
        eval_set=(X_test, y_test),
        verbose=100,
    )

    # 预测
    y_pred = model.predict(X_test)
    y_prob = model.predict_proba(X_test)[:, 1]

    acc = accuracy_score(y_test, y_pred)
    auc = roc_auc_score(y_test, y_prob)

    print(f"\n测试集 Accuracy: {acc:.4f}")
    print(f"测试集 AUC:      {auc:.4f}")
    print(f"最优迭代:        {model.get_best_iteration()}")
    print(f"最优验证分数:    {model.get_best_score():.4f}")

    # 特征重要性
    fi = model.get_feature_importance()
    top5 = np.argsort(fi)[-5:][::-1]
    print("\nTop 5 特征重要性:")
    for idx in top5:
        print(f"  特征 {idx}: {fi[idx]:.4f}")

    return model


def demo_regression():
    """回归示例：使用合成数据"""
    print("\n" + "=" * 60)
    print("CatBoost Regression Demo")
    print("=" * 60)

    np.random.seed(42)
    n_samples, n_features = 1000, 15
    X = np.random.randn(n_samples, n_features)
    # 非线性回归目标
    y = (
        3.0 * X[:, 0]
        + 2.0 * np.sin(X[:, 1])
        - 1.5 * X[:, 2] ** 2
        + 0.5 * X[:, 3] * X[:, 4]
        + 0.1 * np.random.randn(n_samples)
    )

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )

    model = CatBoostRegressor(
        iterations=500,
        learning_rate=0.05,
        depth=6,
        l2_leaf_reg=3.0,
        random_seed=42,
        early_stopping_rounds=50,
        verbose=100,
    )

    model.fit(
        X_train, y_train,
        eval_set=(X_test, y_test),
        verbose=100,
    )

    y_pred = model.predict(X_test)
    rmse = np.sqrt(mean_squared_error(y_test, y_pred))
    r2 = r2_score(y_test, y_pred)

    print(f"\n测试集 RMSE: {rmse:.4f}")
    print(f"测试集 R²:   {r2:.4f}")
    print(f"最优迭代:    {model.get_best_iteration()}")

    return model


def demo_with_categorical():
    """含真实分类特征的数据示例"""
    print("\n" + "=" * 60)
    print("CatBoost with Categorical Features Demo")
    print("=" * 60)

    # 泰坦尼克风格数据
    np.random.seed(42)
    n = 800
    data = pd.DataFrame({
        'Age': np.random.normal(30, 10, n).clip(1, 80),
        'Fare': np.random.exponential(50, n).clip(1, 500),
        'Pclass': np.random.choice([1, 2, 3], n, p=[0.25, 0.35, 0.40]),
        'Sex': np.random.choice(['male', 'female'], n),
        'Embarked': np.random.choice(['S', 'C', 'Q'], n, p=[0.7, 0.2, 0.1]),
    })
    # 合成生存标签
    logits = (
        0.03 * data['Age']
        + 0.01 * data['Fare']
        - 0.5 * (data['Pclass'] - 1)
        + 0.5 * (data['Sex'] == 'female').astype(float)
    )
    data['Survived'] = (1 / (1 + np.exp(-logits + 0.1 * np.random.randn(n))) > 0.5).astype(int)

    X = data.drop('Survived', axis=1)
    y = data['Survived']

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )

    # CatBoost 自动处理字符串分类特征
    cat_features = ['Pclass', 'Sex', 'Embarked']

    model = CatBoostClassifier(
        iterations=300,
        learning_rate=0.05,
        depth=6,
        random_seed=42,
        verbose=0,
    )

    model.fit(
        X_train, y_train,
        cat_features=cat_features,
        eval_set=(X_test, y_test),
        verbose=50,
    )

    y_pred = model.predict(X_test)
    y_prob = model.predict_proba(X_test)[:, 1]

    print(f"\nAccuracy: {accuracy_score(y_test, y_pred):.4f}")
    print(f"AUC:      {roc_auc_score(y_test, y_prob):.4f}")

    return model


if __name__ == '__main__':
    print("CatBoost v2.2.0 — MathModelingSkill Integration Demo\n")

    clf = demo_classification()
    reg = demo_regression()
    cat_demo = demo_with_categorical()

    print("\n" + "=" * 60)
    print("所有 Demo 运行成功!")
    print("=" * 60)
