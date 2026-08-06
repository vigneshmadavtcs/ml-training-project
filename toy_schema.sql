CREATE TABLE predictions (
    id INTEGER PRIMARY KEY,
    prediction_date DATE,
    class_label TEXT,
    confidence_score FLOAT,
    predicted_label TEXT
);

INSERT INTO predictions (id, prediction_date, class_label, confidence_score, predicted_label) VALUES
(1, '2026-08-01', 'setosa', 0.95, 'setosa'),
(2, '2026-08-01', 'versicolor', 0.72, 'versicolor'),
(3, '2026-08-01', 'virginica', 0.88, 'virginica'),
(4, '2026-08-01', 'setosa', 0.91, 'setosa'),
(5, '2026-08-02', 'versicolor', 0.65, 'versicolor'),
(6, '2026-08-02', 'virginica', 0.55, 'versicolor'),
(7, '2026-08-02', 'setosa', 0.93, 'setosa'),
(8, '2026-08-02', 'versicolor', 0.60, 'virginica'),
(9, '2026-08-03', 'virginica', 0.45, 'versicolor'),
(10, '2026-08-03', 'setosa', 0.89, 'setosa'),
(11, '2026-08-03', 'versicolor', 0.50, 'virginica'),
(12, '2026-08-03', 'virginica', 0.40, 'setosa');

CREATE TABLE ground_truth (
    id INTEGER PRIMARY KEY,
    actual_label TEXT
);

INSERT INTO ground_truth (id, actual_label) VALUES
(1, 'setosa'),
(2, 'virginica'),
(3, 'virginica'),
(4, 'setosa'),
(5, 'versicolor'),
(6, 'virginica'),
(7, 'setosa'),
(8, 'versicolor'),
(9, 'virginica'),
(10, 'setosa'),
(11, 'versicolor'),
(12, 'virginica');


Questions:

1.JOIN predictions with ground_truth on id, add a computed column (predicted_label = actual_label) for per-row correctness.
2.Window function — RANK() or ROW_NUMBER() over PARTITION BY class_label ORDER BY confidence_score DESC.
3.LAG()/LEAD() — first aggregate daily accuracy (needs the JOIN result grouped by prediction_date), then LAG() that over date order to compare day-over-day.
4. GROUP BY + HAVING — GROUP BY class_label HAVING AVG(confidence_score) < 0.6 (or whatever threshold reveals the drift).
    
Answer:

1.Anwer_key :SELECT p.*, g.actual_label,
       CASE WHEN p.predicted_label = g.actual_label THEN 1 ELSE 0 END AS is_correct
FROM predictions p
JOIN ground_truth g ON p.id = g.id;

2.Anwer_key : select *, ROW_NUMBER() over (PARTITION BY class_label ORDER BY confidence_score DESC) from predictions;

4.Anwer_key :select class_label from predictions GROUP BY class_label HAVING AVG(confidence_score) < 0.6;

3. Answer_key daily aggregate Answer  : SELECT

 p.prediction_date,
 COUNT(*) AS total_predictions,
 SUM(CASE
         WHEN p.predicted_label = g.actual_label THEN 1
         ELSE 0
     END) AS correct_predictions,
 ROUND(
     100.0 * SUM(CASE
                     WHEN p.predicted_label = g.actual_label THEN 1
                     ELSE 0
                 END) / COUNT(*),
     2
 ) AS accuracy
FROM predictions p
JOIN ground_truth g
ON p.id = g.id
GROUP BY p.prediction_date
ORDER BY p.prediction_date;

LAG using answer :WITH daily_accuracy AS (

 SELECT
     p.prediction_date,
     ROUND(
         100.0 *
         SUM(
             CASE
                 WHEN p.predicted_label = g.actual_label THEN 1
                 ELSE 0
             END
         ) / COUNT(*),
         2
     ) AS accuracy
 FROM predictions p
 JOIN ground_truth g
     ON p.id = g.id
 GROUP BY p.prediction_date
)
SELECT
 prediction_date,
 accuracy,
 LAG(accuracy, 1, NULL) OVER (
     ORDER BY prediction_date
 ) AS previous_day_accuracy,
 accuracy -
 LAG(accuracy, 1, accuracy) OVER (
     ORDER BY prediction_date
 ) AS accuracy_change
FROM daily_accuracy
ORDER BY prediction_date;
