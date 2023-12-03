% Rule to infer if a statement reflects a structured or flexible writing style

infer_mbti(StructuredWriting, FlexibleWriting, MBTI_Type) :-
    StructuredWriting = true, !,
    MBTI_Type = 'Judging'.

infer_mbti(StructuredWriting, FlexibleWriting, MBTI_Type) :-
    FlexibleWriting = true, !,
    MBTI_Type = 'Perceiving'.

infer_mbti(_, _, 'Unknown'). % Default case
