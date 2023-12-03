% Questions for each MBTI dimension
question(introvert_extrovert, 'Do you prefer solitary activities or social gatherings?').
question(sensing_intuition, 'Do you pay more attention to facts and details or to ideas and concepts?').
question(thinking_feeling, 'When making decisions, do you prioritize logic or personal values?').
question(judging_perceiving, 'Do you prefer to have a planned routine or to go with the flow?').

% Keywords for responses
response_keywords(introvert, ['solitary', 'alone', 'quiet']).
response_keywords(extrovert, ['social', 'parties', 'gatherings']).
response_keywords(sensing, ['facts', 'details', 'practical']).
response_keywords(intuition, ['ideas', 'concepts', 'imagination']).
response_keywords(thinking, ['logic', 'rational', 'objective']).
response_keywords(feeling, ['values', 'compassion', 'emotions']).
response_keywords(judging, ['planned', 'routine', 'organized']).
response_keywords(perceiving, ['flow', 'spontaneous', 'flexible']).

% Determine if a response matches keywords
matches_keywords(Response, Category) :-
    response_keywords(Category, Keywords),
    member(Word, Response),
    member(Word, Keywords), !.

% Infer preference for each dimension
infer_preference(Dimension, Response, Preference) :-
    matches_keywords(Response, Category),
    dimension_category(Dimension, Category, Preference), !.
infer_preference(_, _, unknown).

% Map categories to dimensions
dimension_category(introvert_extrovert, introvert, 'I').
dimension_category(introvert_extrovert, extrovert, 'E').
dimension_category(sensing_intuition, sensing, 'S').
dimension_category(sensing_intuition, intuition, 'N').
dimension_category(thinking_feeling, thinking, 'T').
dimension_category(thinking_feeling, feeling, 'F').
dimension_category(judging_perceiving, judging, 'J').
dimension_category(judging_perceiving, perceiving, 'P').

% Compile MBTI type from responses to questions
compile_mbti_type(Responses, MBTI_Type) :-
    findall(Preference, (question(Dimension, _), member(Dimension-Response, Responses), infer_preference(Dimension, Response, Preference)), Preferences),
    atomic_list_concat(Preferences, MBTI_Type).

% Ask questions and infer MBTI type
ask_questions_and_infer_mbti_type(MBTI_Type) :-
    findall(Dimension-Response, (question(Dimension, Q), writeln(Q), read(Response)), Responses),
    compile_mbti_type(Responses, MBTI_Type).

% Detect ambiguous response
is_ambiguous(Dimension, Response) :-
    dimension_category(Dimension, Category1, _),
    dimension_category(Dimension, Category2, _),
    Category1 \= Category2,
    response_keywords(Category1, Keywords1),
    response_keywords(Category2, Keywords2),
    matches_keywords(Response, Keywords1),
    matches_keywords(Response, Keywords2).

% Additional follow-up questions for each dimension
follow_up_question(introvert_extrovert, 'Do you feel recharged after spending time alone?').
follow_up_question(sensing_intuition, 'Do you prefer working with well-established facts or exploring new possibilities?').
follow_up_question(thinking_feeling, 'Are your decisions more guided by objective standards or personal concerns?').
follow_up_question(judging_perceiving, 'Do you find comfort in routines or in adapting as you go?').

% Handle ambiguous responses by asking follow-up questions
handle_ambiguous_response(Dimension, Response, FollowUpResponse, Preference) :-
    is_ambiguous(Dimension, Response),
    follow_up_question(Dimension, FollowUpQuestion),
    writeln(FollowUpQuestion),
    read(FollowUpResponse),
    infer_preference_from_followup(Dimension, FollowUpResponse, Preference).

% Infer preference from follow-up response
infer_preference_from_followup(Dimension, Response, Preference) :-
    matches_keywords(Response, Category),
    dimension_category(Dimension, Category, Preference), !.
infer_preference_from_followup(_, _, unknown).

% Adjust infer_preference to include handling ambiguous responses
infer_preference(Dimension, Response, Preference) :-
    (is_ambiguous(Dimension, Response) ->
        handle_ambiguous_response(Dimension, Response, FollowUpResponse, Preference);
        matches_keywords(Response, Category) ->
        dimension_category(Dimension, Category, Preference);
        Preference = unknown).

% Detecting negations and qualifiers in the response
contains_negation(Response) :-
    member(NegationWord, ['not', 'no', 'never', 'none']),
    member(NegationWord, Response).

% Contextual match considering negations
contextual_match(Response, Category) :-
    response_keywords(Category, Keywords),
    member(Word, Response),
    member(Word, Keywords),
    \+ contains_negation(Response).

% Adjust matching keywords to consider negations
matches_keywords_with_context(Response, Category) :-
    response_keywords(Category, Keywords),
    member(Word, Response),
    member(Word, Keywords),
    \+ contains_negation(Response), !.

% Adjust infer_preference to use matches_keywords_with_context
infer_preference_with_context(Dimension, Response, Preference) :-
    (is_ambiguous(Dimension, Response) ->
        handle_ambiguous_response(Dimension, Response, FollowUpResponse, Preference);
        matches_keywords_with_context(Response, Category) ->
        dimension_category(Dimension, Category, Preference);
        Preference = unknown).

% Run MBTI test with dynamic input
run_mbti_test :-
    ask_questions_and_infer_mbti_type(MBTI_Type),
    format('Calculated MBTI Type: ~w~n', [MBTI_Type]).

% Entry point for dynamic test
:- initialization(run_mbti_test).

% Add this to your Prolog script
run_mbti_test(MBTI_Type) :-
    ask_questions_and_infer_mbti_type(MBTI_Type).
