CREATE TABLE model_predictions (
    id INTEGER PRIMARY KEY,
    prediction_date DATE,
    class_label TEXT,
    confidence_score FLOAT,
    predicted_label TEXT,
    actual_label TEXT
);

INSERT INTO model_predictions (id, prediction_date, class_label, confidence_score, predicted_label, actual_label) VALUES
(1, '2026-08-01', 'setosa', 0.95, 'setosa', 'setosa'),
(2, '2026-08-01', 'versicolor', 0.72, 'versicolor', 'virginica'),
(3, '2026-08-01', 'virginica', 0.88, 'virginica', 'virginica'),
(4, '2026-08-01', 'setosa', 0.91, 'setosa', 'setosa'),
(5, '2026-08-02', 'versicolor', 0.65, 'versicolor', 'versicolor'),
(6, '2026-08-02', 'virginica', 0.55, 'versicolor', 'virginica'),
(7, '2026-08-02', 'setosa', 0.93, 'setosa', 'setosa'),
(8, '2026-08-02', 'versicolor', 0.60, 'virginica', 'versicolor'),
(9, '2026-08-03', 'virginica', 0.45, 'versicolor', 'virginica'),
(10, '2026-08-03', 'setosa', 0.89, 'setosa', 'setosa'),
(11, '2026-08-03', 'versicolor', 0.50, 'virginica', 'versicolor'),
(12, '2026-08-03', 'virginica', 0.40, 'setosa', 'virginica');