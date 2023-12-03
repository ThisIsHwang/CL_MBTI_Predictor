% Define keywords for each MBTI dimension
introvert_keywords(['reading', 'meditation', 'solitude', 'relaxing']).
extrovert_keywords(['party', 'networking', 'friends', 'socializing']).
sensing_keywords(['details', 'facts', 'practical', 'experiences']).
intuition_keywords(['ideas', 'imagination', 'theories', 'possibilities']).
thinking_keywords(['logic', 'analysis', 'objective', 'rational']).
feeling_keywords(['emotions', 'values', 'compassionate', 'empathetic']).
judging_keywords(['organized', 'planned', 'decisive', 'structured']).
perceiving_keywords(['spontaneous', 'flexible', 'open', 'adaptable']).

% Check if a list of words contains any keyword from a given list
contains_keyword(Words, Keywords) :-
    member(Word, Words),
    member(Word, Keywords), !.

% Infer dimension preference
infer_dimension(Dimension, Words, yes) :-
    DimensionKeywords =.. [Dimension, Keywords],
    DimensionKeywords,
    contains_keyword(Words, Keywords), !.
infer_dimension(_, _, no).

% Compile MBTI type from individual dimension preferences
compile_mbti_type(Answers, MBTI_Type) :-
    maplist(determine_preference(Answers), [introvert_keywords, extrovert_keywords, sensing_keywords, intuition_keywords, thinking_keywords, feeling_keywords, judging_keywords, perceiving_keywords], Preferences),
    maplist(infer_mbti_letter, Preferences, Letters),
    atomic_list_concat(Letters, MBTI_Type).

% Determine preference for each MBTI dimension
determine_preference(Answers, Dimension, Dimension-Pref) :-
    findall(P, (member(Answer, Answers), infer_dimension(Dimension, Answer, P)), Ps),
    ( member(yes, Ps) -> Pref = yes ; Pref = no ).

% Map dimension preference to MBTI letter
infer_mbti_letter(introvert_keywords-yes, 'I').
infer_mbti_letter(extrovert_keywords-yes, 'E').
infer_mbti_letter(sensing_keywords-yes, 'S').
infer_mbti_letter(intuition_keywords-yes, 'N').
infer_mbti_letter(thinking_keywords-yes, 'T').
infer_mbti_letter(feeling_keywords-yes, 'F').
infer_mbti_letter(judging_keywords-yes, 'J').
infer_mbti_letter(perceiving_keywords-yes, 'P').
infer_mbti_letter(introvert_keywords-no, ''). % No strong preference inferred
infer_mbti_letter(extrovert_keywords-no, ''). % No strong preference inferred
infer_mbti_letter(sensing_keywords-no, ''). % No strong preference inferred
infer_mbti_letter(intuition_keywords-no, ''). % No strong preference inferred
infer_mbti_letter(thinking_keywords-no, ''). % No strong preference inferred
infer_mbti_letter(feeling_keywords-no, ''). % No strong preference inferred
infer_mbti_letter(judging_keywords-no, ''). % No strong preference inferred
infer_mbti_letter(perceiving_keywords-no, ''). % No strong preference inferred

% Sample input and inference
infer_my_mbti_type(MBTI_Type) :-
    Answers = [
        ['I', 'enjoy', 'meditation', 'evenings', 'at', 'home'],  % Introverted
        ['I', 'like', 'to', 'explore', 'new', 'ideas'],      % Intuitive
        ['emotions', 'guide', 'my', 'decisions'],           % Feeling
        ['I', 'prefer', 'keeping', 'my', 'options', 'open'] % Perceiving
    ],
    compile_mbti_type(Answers, MBTI_Type).
