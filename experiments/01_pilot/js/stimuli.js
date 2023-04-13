// data for all stimuli in the form of a list of JavaScript objects

// TODO: iterate names?

var all_stims =
  [{
    "adjective": "fast", // randomize #1
    "adjectivePair": "fast-slow",
    "polarity": "pos",
    "target": "human", // randomize #2
    "value": "flipped", // randomize #2
    "negation": "1", // randomize #2
    "name": "Jane",
    "context": "Jane is taking an Uber to the airport. She wants the driver to drive slowly because she gets carsick. Once she's gotten off the Uber, she calls her colleague, who she was texting about her issue during the Uber ride. Jane says: ", 
    "sentence": "His driving wasn't fast.",
    "questionState": "What was the speed of the Uber driver?",
    "questionValue": "What speed did Jane want the Uber driver to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "slow", 
    "adjectivePair": "fast-slow",
    "polarity": "neg",
    "target": "human", 
    "value": "flipped", 
    "negation": "1", 
    "name": "Jane",
    "context": "some slow human flipped context", 
    "sentence": "His driving wasn't slow.",
    "questionState": "What was the speed of the Uber driver?",
    "questionValue": "What speed did Jane want the Uber driver to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "big", 
    "adjectivePair": "big-small",
    "polarity": "pos",
    "target": "human", 
    "value": "normal", 
    "negation": "0", 
    "name": "Jane",
    "context": "some big human normal context", 
    "sentence": "Something was big.",
    "questionState": "What was the size of something?",
    "questionValue": "What size did Jane want something to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "small", 
    "adjectivePair": "big-small",
    "polarity": "neg",
    "target": "thing", 
    "value": "normal", 
    "negation": "1", 
    "name": "Jane",
    "context": "some small thing normal context", 
    "sentence": "Something wasn't small.",
    "questionState": "What was the size of something?",
    "questionValue": "What size did Jane want something to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "good", 
    "adjectivePair": "good-bad",
    "polarity": "pos",
    "target": "thing", 
    "value": "normal", 
    "negation": "1", 
    "name": "Jane",
    "context": "some good thing normal context", 
    "sentence": "Something wasn't good.",
    "questionState": "What was the quality of something?",
    "questionValue": "What quality did Jane want something to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "bad", 
    "adjectivePair": "good-bad",
    "polarity": "neg",
    "target": "thing", 
    "value": "normal", 
    "negation": "1", 
    "name": "Jane",
    "context": "some bad thing normal context", 
    "sentence": "Something wasn't bad.",
    "questionState": "What was the quality of something?",
    "questionValue": "What quality did Jane want something to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "long", 
    "adjectivePair": "long-short",
    "polarity": "pos",
    "target": "thing", 
    "value": "normal", 
    "negation": "1", 
    "name": "Jane",
    "context": "some long thing normal context", 
    "sentence": "Something wasn't long.",
    "questionState": "What was the length of something?",
    "questionValue": "What length did Jane want something to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "short", 
    "adjectivePair": "long-short",
    "polarity": "neg",
    "target": "thing", 
    "value": "normal", 
    "negation": "1", 
    "name": "Jane",
    "context": "some short thing normal context", 
    "sentence": "Something wasn't short.",
    "questionState": "What was the length of something?",
    "questionValue": "What length did Jane want something to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
]

// var all_contexts =
//   [{
//     "adjective": "fast-slow",
//     "target": "human",
//     "value": "flip",
//     "context": "Jane is taking an Uber to the airport. She wants the driver to drive slowly because she gets carsick. Once she's gotten off the Uber, she calls her colleague, who she was texting about her issue during the Uber ride. Jane says: ",
//     "questionState": "What was the speed of the Uber driver?",
//     "questionValue": "What speed did Jane want the Uber driver to have?"
//   }]

// var all_sentences =
//   [{"adjective": "fast-slow",
//     "target": "human",
//     "polarity": "pos",
//     "negation": "1",
//     "sentence": "His driving wasn't fast.",
//     "questionIntention": "What was Jane's intention for saying 'His driving wasn't fast'?" // it has both target sentence AND speaker's name -> where does it belong?
//   }]