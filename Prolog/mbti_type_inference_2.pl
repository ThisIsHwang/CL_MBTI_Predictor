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

% Existing code remains the same...

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

infer_preference_with_negation(Dimension, Response, Preference) :-
    dimension_category(Dimension, Category1, Pref1),
    dimension_category(Dimension, Category2, Pref2),
    Category1 \= Category2,
    (matches_keywords(Response, Category1) -> Preference = Pref2; Preference = Pref1).

% Adjust infer_preference to include handling ambiguous responses
infer_preference(Dimension, Response, Preference) :-
    (is_ambiguous(Dimension, Response) ->
        handle_ambiguous_response(Dimension, Response, FollowUpResponse, Preference);
        contains_negation(Response) ->
        infer_preference_with_negation(Dimension, Response, Preference);
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

% Updated ask_questions_and_infer_mbti_type predicate to use infer_preference_with_context
ask_questions_and_infer_mbti_type_with_context(MBTI_Type) :-
    findall(Dimension-Response, (question(Dimension, Q), writeln(Q), read(Response)), Responses),
    findall(Preference, (question(Dimension, _), member(Dimension-Response, Responses), infer_preference_with_context(Dimension, Response, Preference)), Preferences),
    atomic_list_concat(Preferences, MBTI_Type).


% Adjust infer_preference to use contextual_match and handle negations
infer_preference(Dimension, Response, Preference) :-
    (is_ambiguous(Dimension, Response) ->
        handle_ambiguous_response(Dimension, Response, FollowUpResponse, Preference);
        contextual_match(Response, Category) ->
        dimension_category(Dimension, Category, Preference);
        contains_negation(Response) ->
        opposite_dimension(Dimension, OppositePreference), Preference = OppositePreference;
        Preference = unknown).

% Define the opposite preference for each dimension
opposite_dimension(introvert_extrovert, 'E').
opposite_dimension(sensing_intuition, 'N').
opposite_dimension(thinking_feeling, 'F').
opposite_dimension(judging_perceiving, 'P').

% Adjusted points for Introversion and Extraversion keywords
keyword_points('solitary', introvert, 2).
keyword_points('alone', introvert, 1).
keyword_points('quiet', introvert, 1).
keyword_points('social', extrovert, 2).
keyword_points('parties', extrovert, 2).
keyword_points('gatherings', extrovert, 1).

% Adjusted points for Sensing and Intuition keywords
keyword_points('facts', sensing, 2).
keyword_points('details', sensing, 2).
keyword_points('practical', sensing, 1).
keyword_points('ideas', intuition, 2).
keyword_points('concepts', intuition, 2).
keyword_points('imagination', intuition, 1).

% Adjusted points for Thinking and Feeling keywords
keyword_points('logic', thinking, 2).
keyword_points('rational', thinking, 1).
keyword_points('objective', thinking, 1).
keyword_points('values', feeling, 2).
keyword_points('compassion', feeling, 1).
keyword_points('emotions', feeling, 1).

% Adjusted points for Judging and Perceiving keywords
keyword_points('planned', judging, 2).
keyword_points('routine', judging, 1).
keyword_points('organized', judging, 1).
keyword_points('flow', perceiving, 2).
keyword_points('spontaneous', perceiving, 1).
keyword_points('flexible', perceiving, 1).


% Calculate score for a response
calculate_score(_, [], 0).
calculate_score(Category, [Word|Words], Score) :-
    (keyword_points(Word, Category, Points) ->
        calculate_score(Category, Words, RemainingScore),
        Score is Points + RemainingScore;
        calculate_score(Category, Words, Score)).

% Determine the preference based on scores
determine_preference_by_score(Dimension, Response, Preference) :-
    dimension_category(Dimension, Category1, _),
    dimension_category(Dimension, Category2, _),
    calculate_score(Category1, Response, Score1),
    calculate_score(Category2, Response, Score2),
    (Score1 > Score2 ->
        dimension_category(Dimension, Category1, Preference);
        dimension_category(Dimension, Category2, Preference)).

% Adjust infer_preference to use determine_preference_by_score
infer_preference(Dimension, Response, Preference) :-
    determine_preference_by_score(Dimension, Response, Preference).

% Test procedure

 % I think I like social gatherings more
 % I think I pay more attention to facts and details
 % I prioritize logic more
 % I prefer a planned routine
%run_mbti_test(MBTI_Type) :-
%    TestResponses = [
%        introvert_extrovert-['I', 'think', 'social', 'gatherings'],
%        sensing_intuition-['I', 'facts', 'on', 'facts', 'and', 'details'],
%        thinking_feeling-['I', 'prioritize', 'logic'],
%        judging_perceiving-['I', 'like', 'planned', 'routine']
%    ],
%    compile_mbti_type(TestResponses, MBTI_Type).

% Predicate to ask a question and get a response from the user
ask_user(Dimension, Response) :-
    question(Dimension, Q),
    format('~w: ', [Q]),
    read_line_to_string(user_input, StringResponse),
    split_string(StringResponse, " ", "", SplitResponse),
    Response = Dimension-SplitResponse.

% Predicate to run MBTI test with dynamic user input
run_mbti_test(MBTI_Type) :-
    findall(Response, (dimension_category(Dimension, _, _), ask_user(Dimension, Response)), TestResponses),
    compile_mbti_type(TestResponses, MBTI_Type).

% Call this predicate to run the test with user input
test_mbti :-
    run_mbti_test(MBTI_Type),
    format('Calculated MBTI Type: ~w~n', [MBTI_Type]).