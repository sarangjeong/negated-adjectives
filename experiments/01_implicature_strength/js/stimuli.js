// data for all stimuli in the form of a list of JavaScript objects

// TODO: iterate names?

var all_stims =
  [{
    "adjective": "fast-slow",
    "polarity": "pos",
    "target": "human",
    "value": "flip",
    "negation": "1",
    "context": "Jane is taking an Uber to the airport. She wants the driver to drive slowly because she gets carsick. Once she's gotten off the Uber, she calls her colleague, who she was texting about her issue during the Uber ride. Jane says: ", 
    "sentence": "His driving wasn't fast.",
    "questionState": "What was the speed of the Uber driver?",
    "questionValue": "What speed did Jane want the Uber driver to have?",
    "questionIntention": "What was Jane's intention for saying 'His driving wasn't fast'?"
  }]

var all_contexts =
  [{
    "adjective": "fast-slow",
    "target": "human",
    "value": "flip",
    "context": "Jane is taking an Uber to the airport. She wants the driver to drive slowly because she gets carsick. Once she's gotten off the Uber, she calls her colleague, who she was texting about her issue during the Uber ride. Jane says: ",
    "questionState": "What was the speed of the Uber driver?",
    "questionValue": "What speed did Jane want the Uber driver to have?"
  }]

var all_sentences =
  [{"adjective": "fast-slow",
    "target": "human",
    "polarity": "pos",
    "negation": "1",
    "sentence": "His driving wasn't fast.",
    "questionIntention": "What was Jane's intention for saying 'His driving wasn't fast'?" // it has both target sentence AND speaker's name -> where does it belong?
  }]