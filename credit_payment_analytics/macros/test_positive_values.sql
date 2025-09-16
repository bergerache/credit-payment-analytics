-- This macro tests that all values in the specified column are positive (greater than or equal to zero).

{% macro test_positive_values(model, column_name) %}
    SELECT *
    FROM {{ model }}
    WHERE {{ column_name }} < 0
{% endmacro %}