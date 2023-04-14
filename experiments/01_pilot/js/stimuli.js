// data for all stimuli in the form of a list of JavaScript objects

// TODO: iterate names?

var adjectives = ["good", "bad", "fast", "slow", "big", "small", "long", "short"];

var targets = ["human", "thing"];
var values = ["normal", "flipped"];
var negations = ["1", "0"];

var conditions = [];

for (let i = 0; i < targets.length; i++) {
  for (let j = 0; j < values.length; j++) {
    for (let k = 0; k < negations.length; k++) {
      conditions.push([targets[i], values[j], negations[k]])
    }
  }
}

adjectives = _.shuffle(adjectives)
conditions = _.shuffle(conditions)

var all_stims =
  [
  // 1. fast
  {
    "adjective": "fast", // 1. fast - human - flip - neg O
    "adjectivePair": "fast-slow",
    "polarity": "pos",
    "target": "human", 
    "value": "flipped", 
    "negation": "1", 
    // "name": "Jane",
    "context": "Jane is taking an Uber to the airport. She wants the driver to drive slowly because she gets carsick. Once she's made it to the gate, she calls her colleague, who she was texting about her issue during the Uber ride. Jane says: ", 
    "sentence": "His driving wasn't fast.",
    "questionState": "What was the speed of the Uber driver?",
    "questionValue": "What speed did Jane want the Uber driver to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "fast", // 2. fast - human - flip - neg X
    "adjectivePair": "fast-slow",
    "polarity": "pos",
    "target": "human", 
    "value": "flipped", 
    "negation": "0", 
    "context": "fast human flipped context", 
    "sentence": "His driving was fast.",
    "questionState": "What was the speed of the Uber driver?",
    "questionValue": "What speed did Jane want the Uber driver to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "fast", // 3. fast - human - normal - neg O
    "adjectivePair": "fast-slow",
    "polarity": "pos",
    "target": "human", 
    "value": "normal", 
    "negation": "1", 
    "context": "fast human normal context", 
    "sentence": "His driving wasn't fast.",
    "questionState": "What was the speed of the Uber driver?",
    "questionValue": "What speed did Jane want the Uber driver to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "fast", // 4. fast - human - normal - neg X
    "adjectivePair": "fast-slow",
    "polarity": "pos",
    "target": "human", 
    "value": "normal", 
    "negation": "0", 
    "context": "fast human normal context", 
    "sentence": "His driving was fast.",
    "questionState": "What was the speed of the Uber driver?",
    "questionValue": "What speed did Jane want the Uber driver to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "fast", // 5. fast - thing - flip - neg O
    "adjectivePair": "fast-slow",
    "polarity": "pos",
    "target": "thing", 
    "value": "flipped", 
    "negation": "1", 
    "context": "fast thing flip context", 
    "sentence": "The zebra wasn't fast.",
    "questionState": "What was the speed of the zebra?",
    "questionValue": "What speed did Jane want the zebra to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "fast", // 6. fast - thing - flip - neg X
    "adjectivePair": "fast-slow",
    "polarity": "pos",
    "target": "thing", 
    "value": "flipped", 
    "negation": "0", 
    "context": "fast thing flipped context", 
    "sentence": "The zebra was fast.",
    "questionState": "What was the speed of the zebra?",
    "questionValue": "What speed did Jane want the zebra to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "fast", // 7. fast - thing - normal - neg O
    "adjectivePair": "fast-slow",
    "polarity": "pos",
    "target": "thing", 
    "value": "normal", 
    "negation": "1", 
    "context": "fast thing normal context", 
    "sentence": "The zebra wasn't fast.",
    "questionState": "What was the speed of the zebra?",
    "questionValue": "What speed did Jane want the zebra to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "fast", // 8. fast - thing - normal - neg X
    "adjectivePair": "fast-slow",
    "polarity": "pos",
    "target": "thing", 
    "value": "normal", 
    "negation": "0", 
    "context": "fast thing normal context", 
    "sentence": "The zebra was fast.",
    "questionState": "What was the speed of the zebra?",
    "questionValue": "What speed did Jane want the zebra to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },

  // 2. slow
  {
    "adjective": "slow", // 1. slow - human - flip - neg O
    "adjectivePair": "fast-slow",
    "polarity": "pos",
    "target": "human", 
    "value": "flipped", 
    "negation": "1", 
    "context": "Jane is taking an Uber to the airport. She wants the driver to drive slowly because she gets carsick. Once she's made it to the gate, she calls her colleague, who she was texting about her issue during the Uber ride. Jane says: ", 
    "sentence": "His driving wasn't slow.",
    "questionState": "What was the speed of the Uber driver?",
    "questionValue": "What speed did Jane want the Uber driver to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "slow", // 2. slow - human - flip - neg X
    "adjectivePair": "fast-slow",
    "polarity": "pos",
    "target": "human", 
    "value": "flipped", 
    "negation": "0", 
    "context": "slow human flipped context", 
    "sentence": "His driving was slow.",
    "questionState": "What was the speed of the Uber driver?",
    "questionValue": "What speed did Jane want the Uber driver to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "slow", // 3. slow - human - normal - neg O
    "adjectivePair": "fast-slow",
    "polarity": "pos",
    "target": "human", 
    "value": "normal", 
    "negation": "1", 
    "context": "slow human normal context", 
    "sentence": "His driving wasn't slow.",
    "questionState": "What was the speed of the Uber driver?",
    "questionValue": "What speed did Jane want the Uber driver to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "slow", // 4. slow - human - normal - neg X
    "adjectivePair": "fast-slow",
    "polarity": "pos",
    "target": "human", 
    "value": "normal", 
    "negation": "0", 
    "context": "slow human normal context", 
    "sentence": "His driving was slow.",
    "questionState": "What was the speed of the Uber driver?",
    "questionValue": "What speed did Jane want the Uber driver to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "slow", // 5. slow - thing - flip - neg O
    "adjectivePair": "fast-slow",
    "polarity": "pos",
    "target": "thing", 
    "value": "flipped", 
    "negation": "1", 
    "context": "slow thing flip context", 
    "sentence": "The zebra wasn't slow.",
    "questionState": "What was the speed of the zebra?",
    "questionValue": "What speed did Jane want the zebra to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "slow", // 6. slow - thing - flip - neg X
    "adjectivePair": "fast-slow",
    "polarity": "pos",
    "target": "thing", 
    "value": "flipped", 
    "negation": "0", 
    "context": "slow thing flipped context", 
    "sentence": "The zebra was slow.",
    "questionState": "What was the speed of the zebra?",
    "questionValue": "What speed did Jane want the zebra to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "slow", // 7. slow - thing - normal - neg O
    "adjectivePair": "fast-slow",
    "polarity": "pos",
    "target": "thing", 
    "value": "normal", 
    "negation": "1", 
    "context": "slow thing normal context", 
    "sentence": "The zebra wasn't slow.",
    "questionState": "What was the speed of the zebra?",
    "questionValue": "What speed did Jane want the zebra to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "slow", // 8. slow - thing - normal - neg X
    "adjectivePair": "fast-slow",
    "polarity": "pos",
    "target": "thing", 
    "value": "normal", 
    "negation": "0", 
    "context": "slow thing normal context", 
    "sentence": "The zebra was slow.",
    "questionState": "What was the speed of the zebra?",
    "questionValue": "What speed did Jane want the zebra to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },

  // 3. good
  {
    "adjective": "good", // 1. good - human - flip - neg O
    "adjectivePair": "good-bad",
    "polarity": "pos",
    "target": "human", 
    "value": "flipped", 
    "negation": "1", 
    "context": "good human flip context", 
    "sentence": "He wasn't good.",
    "questionState": "What was the quality of the Uber driver?",
    "questionValue": "What quality did Jane want the Uber driver to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "good", // 2. good - human - flip - neg X
    "adjectivePair": "good-bad",
    "polarity": "pos",
    "target": "human", 
    "value": "flipped", 
    "negation": "0", 
    "context": "good human flipped context", 
    "sentence": "He was good.",
    "questionState": "What was the quality of the Uber driver?",
    "questionValue": "What quality did Jane want the Uber driver to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "good", // 3. good - human - normal - neg O
    "adjectivePair": "good-bad",
    "polarity": "pos",
    "target": "human", 
    "value": "normal", 
    "negation": "1", 
    "context": "good human normal context", 
    "sentence": "He wasn't good.",
    "questionState": "What was the quality of the Uber driver?",
    "questionValue": "What quality did Jane want the Uber driver to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "good", // 4. good - human - normal - neg X
    "adjectivePair": "good-bad",
    "polarity": "pos",
    "target": "human", 
    "value": "normal", 
    "negation": "0", 
    "context": "good human normal context", 
    "sentence": "He was good.",
    "questionState": "What was the quality of the Uber driver?",
    "questionValue": "What quality did Jane want the Uber driver to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "good", // 5. good - thing - flip - neg O
    "adjectivePair": "good-bad",
    "polarity": "pos",
    "target": "thing", 
    "value": "flipped", 
    "negation": "1", 
    "context": "good thing flip context", 
    "sentence": "it wasn't good.",
    "questionState": "What was the quality of it?",
    "questionValue": "What quality did Jane want it to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "good", // 6. good - thing - flip - neg X
    "adjectivePair": "good-bad",
    "polarity": "pos",
    "target": "thing", 
    "value": "flipped", 
    "negation": "0", 
    "context": "good thing flipped context", 
    "sentence": "it was good.",
    "questionState": "What was the quality of it?",
    "questionValue": "What quality did Jane want it to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "good", // 7. good - thing - normal - neg O
    "adjectivePair": "good-bad",
    "polarity": "pos",
    "target": "thing", 
    "value": "normal", 
    "negation": "1", 
    "context": "good thing normal context", 
    "sentence": "it wasn't good.",
    "questionState": "What was the quality of it?",
    "questionValue": "What quality did Jane want it to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "good", // 8. good - thing - normal - neg X
    "adjectivePair": "good-bad",
    "polarity": "pos",
    "target": "thing", 
    "value": "normal", 
    "negation": "0", 
    "context": "good thing normal context", 
    "sentence": "it was good.",
    "questionState": "What was the quality of it?",
    "questionValue": "What quality did Jane want it to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },

  // 4. bad
  {
    "adjective": "bad", // 1. bad - human - flip - neg O
    "adjectivePair": "good-bad",
    "polarity": "pos",
    "target": "human", 
    "value": "flipped", 
    "negation": "1", 
    "context": "Jane is taking an Uber to the airport. She wants the driver to drive badly because she gets carsick. Once she's made it to the gate, she calls her colleague, who she was texting about her issue during the Uber ride. Jane says: ", 
    "sentence": "He wasn't bad.",
    "questionState": "What was the quality of the Uber driver?",
    "questionValue": "What quality did Jane want the Uber driver to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "bad", // 2. bad - human - flip - neg X
    "adjectivePair": "good-bad",
    "polarity": "pos",
    "target": "human", 
    "value": "flipped", 
    "negation": "0", 
    "context": "bad human flipped context", 
    "sentence": "He was bad.",
    "questionState": "What was the quality of the Uber driver?",
    "questionValue": "What quality did Jane want the Uber driver to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "bad", // 3. bad - human - normal - neg O
    "adjectivePair": "good-bad",
    "polarity": "pos",
    "target": "human", 
    "value": "normal", 
    "negation": "1", 
    "context": "bad human normal context", 
    "sentence": "He wasn't bad.",
    "questionState": "What was the quality of the Uber driver?",
    "questionValue": "What quality did Jane want the Uber driver to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "bad", // 4. bad - human - normal - neg X
    "adjectivePair": "good-bad",
    "polarity": "pos",
    "target": "human", 
    "value": "normal", 
    "negation": "0", 
    "context": "bad human normal context", 
    "sentence": "He was bad.",
    "questionState": "What was the quality of the Uber driver?",
    "questionValue": "What quality did Jane want the Uber driver to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "bad", // 5. bad - thing - flip - neg O
    "adjectivePair": "good-bad",
    "polarity": "pos",
    "target": "thing", 
    "value": "flipped", 
    "negation": "1", 
    "context": "bad thing flip context", 
    "sentence": "it wasn't bad.",
    "questionState": "What was the quality of it?",
    "questionValue": "What quality did Jane want it to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "bad", // 6. bad - thing - flip - neg X
    "adjectivePair": "good-bad",
    "polarity": "pos",
    "target": "thing", 
    "value": "flipped", 
    "negation": "0", 
    "context": "bad thing flipped context", 
    "sentence": "it was bad.",
    "questionState": "What was the quality of it?",
    "questionValue": "What quality did Jane want it to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "bad", // 7. bad - thing - normal - neg O
    "adjectivePair": "good-bad",
    "polarity": "pos",
    "target": "thing", 
    "value": "normal", 
    "negation": "1", 
    "context": "bad thing normal context", 
    "sentence": "it wasn't bad.",
    "questionState": "What was the quality of it?",
    "questionValue": "What quality did Jane want it to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "bad", // 8. bad - thing - normal - neg X
    "adjectivePair": "good-bad",
    "polarity": "pos",
    "target": "thing", 
    "value": "normal", 
    "negation": "0", 
    "context": "bad thing normal context", 
    "sentence": "it was bad.",
    "questionState": "What was the quality of it?",
    "questionValue": "What quality did Jane want it to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },

  // 5. long
  {
    "adjective": "long", // 1. long - human - flip - neg O
    "adjectivePair": "long-short",
    "polarity": "pos",
    "target": "human", 
    "value": "flipped", 
    "negation": "1", 
    "context": "long human flip context", 
    "sentence": "He wasn't long.",
    "questionState": "What was the length of the Uber driver?",
    "questionValue": "What length did Jane want the Uber driver to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "long", // 2. long - human - flip - neg X
    "adjectivePair": "long-short",
    "polarity": "pos",
    "target": "human", 
    "value": "flipped", 
    "negation": "0", 
    "context": "long human flipped context", 
    "sentence": "He was long.",
    "questionState": "What was the length of the Uber driver?",
    "questionValue": "What length did Jane want the Uber driver to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "long", // 3. long - human - normal - neg O
    "adjectivePair": "long-short",
    "polarity": "pos",
    "target": "human", 
    "value": "normal", 
    "negation": "1", 
    "context": "long human normal context", 
    "sentence": "He wasn't long.",
    "questionState": "What was the length of the Uber driver?",
    "questionValue": "What length did Jane want the Uber driver to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "long", // 4. long - human - normal - neg X
    "adjectivePair": "long-short",
    "polarity": "pos",
    "target": "human", 
    "value": "normal", 
    "negation": "0", 
    "context": "long human normal context", 
    "sentence": "He was long.",
    "questionState": "What was the length of the Uber driver?",
    "questionValue": "What length did Jane want the Uber driver to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "long", // 5. long - thing - flip - neg O
    "adjectivePair": "long-short",
    "polarity": "pos",
    "target": "thing", 
    "value": "flipped", 
    "negation": "1", 
    "context": "long thing flip context", 
    "sentence": "it wasn't long.",
    "questionState": "What was the length of it?",
    "questionValue": "What length did Jane want it to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "long", // 6. long - thing - flip - neg X
    "adjectivePair": "long-short",
    "polarity": "pos",
    "target": "thing", 
    "value": "flipped", 
    "negation": "0", 
    "context": "long thing flipped context", 
    "sentence": "it was long.",
    "questionState": "What was the length of it?",
    "questionValue": "What length did Jane want it to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "long", // 7. long - thing - normal - neg O
    "adjectivePair": "long-short",
    "polarity": "pos",
    "target": "thing", 
    "value": "normal", 
    "negation": "1", 
    "context": "long thing normal context", 
    "sentence": "it wasn't long.",
    "questionState": "What was the length of it?",
    "questionValue": "What length did Jane want it to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "long", // 8. long - thing - normal - neg X
    "adjectivePair": "long-short",
    "polarity": "pos",
    "target": "thing", 
    "value": "normal", 
    "negation": "0", 
    "context": "long thing normal context", 
    "sentence": "it was long.",
    "questionState": "What was the length of it?",
    "questionValue": "What length did Jane want it to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },

  // 6. short
  {
    "adjective": "short", // 1. short - human - flip - neg O
    "adjectivePair": "long-short",
    "polarity": "pos",
    "target": "human", 
    "value": "flipped", 
    "negation": "1", 
    "context": "Jane is taking an Uber to the airport. She wants the driver to drive shortly because she gets carsick. Once she's made it to the gate, she calls her colleague, who she was texting about her issue during the Uber ride. Jane says: ", 
    "sentence": "He wasn't short.",
    "questionState": "What was the length of the Uber driver?",
    "questionValue": "What length did Jane want the Uber driver to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "short", // 2. short - human - flip - neg X
    "adjectivePair": "long-short",
    "polarity": "pos",
    "target": "human", 
    "value": "flipped", 
    "negation": "0", 
    "context": "short human flipped context", 
    "sentence": "He was short.",
    "questionState": "What was the length of the Uber driver?",
    "questionValue": "What length did Jane want the Uber driver to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "short", // 3. short - human - normal - neg O
    "adjectivePair": "long-short",
    "polarity": "pos",
    "target": "human", 
    "value": "normal", 
    "negation": "1", 
    "context": "short human normal context", 
    "sentence": "He wasn't short.",
    "questionState": "What was the length of the Uber driver?",
    "questionValue": "What length did Jane want the Uber driver to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "short", // 4. short - human - normal - neg X
    "adjectivePair": "long-short",
    "polarity": "pos",
    "target": "human", 
    "value": "normal", 
    "negation": "0", 
    "context": "short human normal context", 
    "sentence": "He was short.",
    "questionState": "What was the length of the Uber driver?",
    "questionValue": "What length did Jane want the Uber driver to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "short", // 5. short - thing - flip - neg O
    "adjectivePair": "long-short",
    "polarity": "pos",
    "target": "thing", 
    "value": "flipped", 
    "negation": "1", 
    "context": "short thing flip context", 
    "sentence": "it wasn't short.",
    "questionState": "What was the length of it?",
    "questionValue": "What length did Jane want it to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "short", // 6. short - thing - flip - neg X
    "adjectivePair": "long-short",
    "polarity": "pos",
    "target": "thing", 
    "value": "flipped", 
    "negation": "0", 
    "context": "short thing flipped context", 
    "sentence": "it was short.",
    "questionState": "What was the length of it?",
    "questionValue": "What length did Jane want it to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "short", // 7. short - thing - normal - neg O
    "adjectivePair": "long-short",
    "polarity": "pos",
    "target": "thing", 
    "value": "normal", 
    "negation": "1", 
    "context": "short thing normal context", 
    "sentence": "it wasn't short.",
    "questionState": "What was the length of it?",
    "questionValue": "What length did Jane want it to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "short", // 8. short - thing - normal - neg X
    "adjectivePair": "long-short",
    "polarity": "pos",
    "target": "thing", 
    "value": "normal", 
    "negation": "0", 
    "context": "short thing normal context", 
    "sentence": "it was short.",
    "questionState": "What was the length of it?",
    "questionValue": "What length did Jane want it to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },

  // 7. big
  {
    "adjective": "big", // 1. big - human - flip - neg O
    "adjectivePair": "big-small",
    "polarity": "pos",
    "target": "human", 
    "value": "flipped", 
    "negation": "1", 
    "context": "big human flip context", 
    "sentence": "He wasn't big.",
    "questionState": "What was the size of the Uber driver?",
    "questionValue": "What size did Jane want the Uber driver to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "big", // 2. big - human - flip - neg X
    "adjectivePair": "big-small",
    "polarity": "pos",
    "target": "human", 
    "value": "flipped", 
    "negation": "0", 
    "context": "big human flipped context", 
    "sentence": "He was big.",
    "questionState": "What was the size of the Uber driver?",
    "questionValue": "What size did Jane want the Uber driver to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "big", // 3. big - human - normal - neg O
    "adjectivePair": "big-small",
    "polarity": "pos",
    "target": "human", 
    "value": "normal", 
    "negation": "1", 
    "context": "big human normal context", 
    "sentence": "He wasn't big.",
    "questionState": "What was the size of the Uber driver?",
    "questionValue": "What size did Jane want the Uber driver to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "big", // 4. big - human - normal - neg X
    "adjectivePair": "big-small",
    "polarity": "pos",
    "target": "human", 
    "value": "normal", 
    "negation": "0", 
    "context": "big human normal context", 
    "sentence": "He was big.",
    "questionState": "What was the size of the Uber driver?",
    "questionValue": "What size did Jane want the Uber driver to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "big", // 5. big - thing - flip - neg O
    "adjectivePair": "big-small",
    "polarity": "pos",
    "target": "thing", 
    "value": "flipped", 
    "negation": "1", 
    "context": "big thing flip context", 
    "sentence": "it wasn't big.",
    "questionState": "What was the size of it?",
    "questionValue": "What size did Jane want it to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "big", // 6. big - thing - flip - neg X
    "adjectivePair": "big-small",
    "polarity": "pos",
    "target": "thing", 
    "value": "flipped", 
    "negation": "0", 
    "context": "big thing flipped context", 
    "sentence": "it was big.",
    "questionState": "What was the size of it?",
    "questionValue": "What size did Jane want it to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "big", // 7. big - thing - normal - neg O
    "adjectivePair": "big-small",
    "polarity": "pos",
    "target": "thing", 
    "value": "normal", 
    "negation": "1", 
    "context": "big thing normal context", 
    "sentence": "it wasn't big.",
    "questionState": "What was the size of it?",
    "questionValue": "What size did Jane want it to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "big", // 8. big - thing - normal - neg X
    "adjectivePair": "big-small",
    "polarity": "pos",
    "target": "thing", 
    "value": "normal", 
    "negation": "0", 
    "context": "big thing normal context", 
    "sentence": "it was big.",
    "questionState": "What was the size of it?",
    "questionValue": "What size did Jane want it to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },

  // 8. small
  {
    "adjective": "small", // 1. small - human - flip - neg O
    "adjectivePair": "big-small",
    "polarity": "pos",
    "target": "human", 
    "value": "flipped", 
    "negation": "1", 
    "context": "Jane is taking an Uber to the airport. She wants the driver to drive smallly because she gets carsick. Once she's made it to the gate, she calls her colleague, who she was texting about her issue during the Uber ride. Jane says: ", 
    "sentence": "He wasn't small.",
    "questionState": "What was the size of the Uber driver?",
    "questionValue": "What size did Jane want the Uber driver to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "small", // 2. small - human - flip - neg X
    "adjectivePair": "big-small",
    "polarity": "pos",
    "target": "human", 
    "value": "flipped", 
    "negation": "0", 
    "context": "small human flipped context", 
    "sentence": "He was small.",
    "questionState": "What was the size of the Uber driver?",
    "questionValue": "What size did Jane want the Uber driver to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "small", // 3. small - human - normal - neg O
    "adjectivePair": "big-small",
    "polarity": "pos",
    "target": "human", 
    "value": "normal", 
    "negation": "1", 
    "context": "small human normal context", 
    "sentence": "He wasn't small.",
    "questionState": "What was the size of the Uber driver?",
    "questionValue": "What size did Jane want the Uber driver to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "small", // 4. small - human - normal - neg X
    "adjectivePair": "big-small",
    "polarity": "pos",
    "target": "human", 
    "value": "normal", 
    "negation": "0", 
    "context": "small human normal context", 
    "sentence": "He was small.",
    "questionState": "What was the size of the Uber driver?",
    "questionValue": "What size did Jane want the Uber driver to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "small", // 5. small - thing - flip - neg O
    "adjectivePair": "big-small",
    "polarity": "pos",
    "target": "thing", 
    "value": "flipped", 
    "negation": "1", 
    "context": "small thing flip context", 
    "sentence": "it wasn't small.",
    "questionState": "What was the size of it?",
    "questionValue": "What size did Jane want it to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "small", // 6. small - thing - flip - neg X
    "adjectivePair": "big-small",
    "polarity": "pos",
    "target": "thing", 
    "value": "flipped", 
    "negation": "0", 
    "context": "small thing flipped context", 
    "sentence": "it was small.",
    "questionState": "What was the size of it?",
    "questionValue": "What size did Jane want it to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "small", // 7. small - thing - normal - neg O
    "adjectivePair": "big-small",
    "polarity": "pos",
    "target": "thing", 
    "value": "normal", 
    "negation": "1", 
    "context": "small thing normal context", 
    "sentence": "it wasn't small.",
    "questionState": "What was the size of it?",
    "questionValue": "What size did Jane want it to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  },
  {
    "adjective": "small", // 8. small - thing - normal - neg X
    "adjectivePair": "big-small",
    "polarity": "pos",
    "target": "thing", 
    "value": "normal", 
    "negation": "0", 
    "context": "small thing normal context", 
    "sentence": "it was small.",
    "questionState": "What was the size of it?",
    "questionValue": "What size did Jane want it to have?",
    "questionHonest": "How important was it for Jane to be honest?",
    "questionPositive": "How important was it for Jane to be positive?"
  }
]

function findStimIndex(adjective, target, value, negation) {
  for (let i = 0; i < all_stims.length; i++) {
    if (all_stims[i].adjective == adjective
      && all_stims[i].target == target
      && all_stims[i].value == value
      && all_stims[i].negation == negation) {
        return i
      }
  }
  console.error("no such stim :(")
}

function makeStimList() {
  var stims = [];
  for (let index = 0; index < adjectives.length; index++) { // this assumes lengths of lists are identical
    var adjective = adjectives[index]
    var [target, value, negation] = conditions[index]; // unpacking 
    var stim = all_stims[findStimIndex(adjective, target, value, negation)];
    stims.push(stim)
  }
  return stims
}

// var all_contexts =
//   [{
//     "adjective": "fast-slow",
//     "target": "human",
//     "value": "flip",
//     "context": "Jane is taking an Uber to the airport. She wants the driver to drive slowly because she gets carsick. Once she's made it to the gate, she calls her colleague, who she was texting about her issue during the Uber ride. Jane says: ",
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