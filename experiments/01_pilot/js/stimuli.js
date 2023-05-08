var adjectives = ["good", "bad", "fast", "slow", "big", "small", "long", "short"];

var target_types = ["human", "thing"];
var values = ["normal", "flipped"];
var negations = ["1", "0"];

var conditions = [];

for (let i = 0; i < target_types.length; i++) {
  for (let j = 0; j < values.length; j++) {
    for (let k = 0; k < negations.length; k++) {
      conditions.push([target_types[i], values[j], negations[k]])
    }
  }
}

adjectives = _.shuffle(adjectives)
conditions = _.shuffle(conditions)

controls = [
    {
        "type": "control",
        "adjective": "tasty",
        "adjective_pair": "tasty-gross",
        "polarity": "positive",
        "target_type": "listener", 
        "state": "negative", 
        "negation": 0, 
        "context1": "Nathaniel is into baking these days. He bakes sugar-free cookies and gives some to his friend, Sarah. Sarah eats one, and it tastes like mud.",
        "context2": "When Nathaniel asks for feedback, Sarah says:",
        "sentence": "\"It's tasty.\"",
        "question": {
            "state": "What was the cookie like?", 
            "value": "Based on what Sarah said, make your best guess: What did Sarah want the cookie to be like?",
            "intention": {
                "instruction": "Think about why Sarah said what she said.",
                "honest": "How important was it to Sarah to say the truth?",
                "positive": "How important was it to Sarah to be positive?"
            }
        },
        "listener_name": "Nathaniel",
        "listener_gender": "M",
        "item": "cookie",
        "name": "Sarah",
        "gender": "F"
    }, {
        "type": "control",
        "adjective": "gross",
        "adjective_pair": "tasty-gross",
        "polarity": "negative",
        "target_type": "listener", 
        "state": "negative", 
        "negation": 0, 
        "context1": "Christina is into baking these days. She bakes butter-free scones and gives some to her friend, Ethan. Ethan eats one, and it tastes like mud.",
        "context2": "When Christina asks for feedback, Ethan says:",
        "sentence": "\"It's gross.\"",
        "question": {
            "state": "What was the scone like?", 
            "value": "Based on what Ethan said, make your best guess: What did Ethan want the scone to be like?",
            "intention": {
                "instruction": "Think about why Ethan said what he said.",
                "honest": "How important was it to Ethan to say the truth?",
                "positive": "How important was it to Ethan to be positive?"
            }
        },
        "listener_name": "Christina",
        "listener_gender": "F",
        "item": "scone",
        "name": "Ethan",
        "gender": "M"
    }, {
        "type": "control",
        "adjective": "tasty",
        "adjective_pair": "tasty-gross",
        "polarity": "positive",
        "target_type": "listener", 
        "state": "positive", 
        "negation": 0, 
        "context1": "Paul is into baking these days. He bakes vegan cupcakes and gives some to his friend, Dora. Dora eats one, and it tastes great.",
        "context2": "When Paul asks for feedback, Dora says:",
        "sentence": "\"It's tasty.\"",
        "question": {
            "state": "What was the cupcake like?", 
            "value": "Based on what Dora said, make your best guess: What did Dora want the cupcake to be like?",
            "intention": {
                "instruction": "Think about why Dora said what she said.",
                "honest": "How important was it to Dora to say the truth?",
                "positive": "How important was it to Dora to be positive?"
            }
        },
        "listener_name": "Paul",
        "listener_gender": "M",
        "item": "cupcake",
        "name": "Dora",
        "gender": "F"
    }, {
        "type": "control",
        "adjective": "gross",
        "adjective_pair": "tasty-gross",
        "polarity": "negative",
        "target_type": "listener", 
        "state": "positive", 
        "negation": 0, 
        "context1": "Penny is into baking these days. She bakes gluten-free bread and gives some to her friend, Robert. Robert eats one loaf, and it tastes great.", // TODO : loaf
        "context2": "When Penny asks for feedback, Robert says:",
        "sentence": "\"It's gross.\"",
        "question": {
            "state": "What was the bread like?", 
            "value": "Based on what Robert said, make your best guess: What did Robert want the bread to be like?",
            "intention": {
                "instruction": "Think about why Robert said what he said.",
                "honest": "How important was it to Robert to say the truth?",
                "positive": "How important was it to Robert to be positive?"
            }
        },
        "listener_name": "Penny",
        "listener_gender": "F",
        "item": "bread",
        "name": "Robert",
        "gender": "M"
    }, { 
        "type": "control",
        "adjective": "entertaining",
        "adjective_pair": "entertaining-boring",
        "polarity": "positive",
        "target_type": "listener", 
        "state": "negative", 
        "negation": 0, 
        "context1": "Emily is trying to be a famous Youtuber. She makes a video clip of herself and sends it to her friend, George. George watches it, and it almost puts him to sleep.",
        "context2": "When Emily asks for feedback, George says:",
        "sentence": "\"It's entertaining.\"",
        "question": {
            "state": "What was the video clip like?", 
            "value": "Based on what George said, make your best guess: What did George want the video clip to be like?",
            "intention": {
                "instruction": "Think about why George said what he said.",
                "honest": "How important was it to George to say the truth?",
                "positive": "How important was it to George to be positive?"
            }
        },
        "listener_name": "Emily",
        "listener_gender": "F",
        "item": "clip",
        "name": "George",
        "gender": "M"
    }, { 
        "type": "control",
        "adjective": "boring",
        "adjective_pair": "entertaining-boring",
        "polarity": "negative",
        "target_type": "listener", 
        "state": "negative", 
        "negation": 0, 
        "context1": "Eric is trying to submit to an amateur film contest. He makes a short film and sends it to his friend, Lucy. Lucy watches it, and it almost puts her to sleep.",
        "context2": "When Eric asks for feedback, Lucy says:",
        "sentence": "\"It's boring.\"",
        "question": {
            "state": "What was the short film like?", 
            "value": "Based on what Lucy said, make your best guess: What did Lucy want the clip to be like?",
            "intention": {
                "instruction": "Think about why Lucy said what she said.",
                "honest": "How important was it to Lucy to say the truth?",
                "positive": "How important was it to Lucy to be positive?"
            }
        },
        "listener_name": "Eric",
        "listener_gender": "M",
        "item": "film",
        "name": "Lucy",
        "gender": "F"
    }, { 
        "type": "control",
        "adjective": "entertaining",
        "adjective_pair": "entertaining-boring",
        "polarity": "positive",
        "target_type": "listener", 
        "state": "positive", 
        "negation": 0, 
        "context1": "Samantha is writing a story for a magazine. She writes a first draft and sends it to her friend, Mark. Mark reads it, and he really enjoys it.",
        "context2": "When Samantha asks for feedback, Mark says:",
        "sentence": "\"It's entertaining.\"",
        "question": {
            "state": "What was the story like?", 
            "value": "Based on what Mark said, make your best guess: What did Mark want the story to be like?",
            "intention": {
                "instruction": "Think about why Mark said what he said.",
                "honest": "How important was it to Mark to say the truth?",
                "positive": "How important was it to Mark to be positive?"
            }
        },
        "listener_name": "Samantha",
        "listener_gender": "F",
        "item": "story",
        "name": "Mark",
        "gender": "M"
    }, { 
        "type": "control",
        "adjective": "boring",
        "adjective_pair": "entertaining-boring",
        "polarity": "negative",
        "target_type": "listener", 
        "state": "positive", 
        "negation": 0, 
        "context1": "Bruce is writing a cartoon for a local newspaper. He writes a first draft and sends it to his friend, Caroline. Caroline reads it, and she really enjoys it.",
        "context2": "When Bruce asks for feedback, Caroline says:",
        "sentence": "\"It's boring.\"",
        "question": {
            "state": "What was the cartoon like?", 
            "value": "Based on what Caroline said, make your best guess: What did Caroline want the cartoon to be like?",
            "intention": {
                "instruction": "Think about why Caroline said what she said.",
                "honest": "How important was it to Caroline to say the truth?",
                "positive": "How important was it to Caroline to be positive?"
            }
        },
        "listener_name": "Bruce",
        "listener_gender": "M",
        "item": "cartoon",
        "name": "Caroline",
        "gender": "F"
    }, 
]

function makeStimList() {
    var stims = [];
    for (let index = 0; index < adjectives.length; index++) { // this assumes length of adjectives & length of conditions are identical
      var adjective = adjectives[index]
      var [target_type, value, negation] = conditions[index]; // unpacking 
      var stim = new Stim(adjective, target_type, value, negation).toDict() 
      stims.push(stim)
    }
    stims = stims.concat(controls);
    stims = _.shuffle(stims);
    return stims
  }

// capitalize sentence-initial nominative
function capitalize(string) {
    return string.charAt(0).toUpperCase() + string.slice(1);
}

class Stim {
    constructor(adjective, target_type, value, negation) {
        this.adjective = adjective
        this.value = value
        this.target_type = target_type
        this.negation = negation

        this.adjective_pair = ""
        this.name = ""
        this.gender = ""
        this.property = ""
        this.target = ""
        this.subject = ""

        this.sentence = ""
        this.common_context = ""
        this.value_context = ""
        this.context1 = ""
        this.context2 = ""
        this.question = {
            "state": "", 
            "value": "",
            "intention": {
                "instruction": "",
                "honest": "",
                "positive": ""
            }
        }
        this.desired = ""

        // Make stim
        this.setPerson()
        this.setAttributeDependentOnAdjective(this.adjective)
        this.setDesired(this.adjective_pair, this.value)
        this.setAttributeDependentOnAdjectivePairAndTargetType(this.adjective_pair, this.target_type)
        this.setPolarity(this.adjective, this.adjective_pair)

        this.setSentence(this.subject, this.negation, this.adjective)
        
        // TODO : define pronouns globally
        let nominative, accusative, possessive
        [nominative, accusative, possessive] = this.getPronouns(this.gender)
        this.question.intention.instruction = `Think about why ${this.name} said what ${nominative} said.` 
        
        this.setValueContext(this.adjective_pair, this.target_type, this.value)
        this.context1 = this.common_context + this.value_context

        this.question.state = `Based on what ${this.name} said, make your best guess: What was the ${this.property} of the ${this.target}?`
        
        // TODO : remove this.property? (maybe not, becaus it's used in state question)
        // TODO : does it sound natural? "What does Jane want the driver to be like?"
        this.question.value = `What does ${this.name} want the ${this.target} to be like?`
        
        this.question.intention.honest = `How important was it to ${this.name} to be honest?`
        this.question.intention.positive = `How important was it to ${this.name} to be positive?`
    }
    
    toDict() {
        return {
            "type": "main_stimulus",
            "adjective": this.adjective,
            "adjective_pair": this.adjective_pair,
            "polarity": this.polarity,
            "target_type": this.target_type, 
            "value": this.value, 
            "negation": this.negation, 
            "context1": this.context1, 
            "context2": this.context2,
            "sentence": this.sentence,
            "question": this.question,
            "name": this.name,
            "gender": this.gender,
            // record more data so that I read off of json what item it is
            "item": this.target, 
            "desired": this.desired
        }
    }

    getPronouns(gender) {
        if (gender == "F") {
            return ["she", "her", "her"]
        } else if (gender == "M") {
            return ["he", "him", "his"]
        }
    }
    
    setAttributeDependentOnAdjectivePairAndTargetType(adjective_pair, target_type) {
        let nominative, accusative, possessive
        [nominative, accusative, possessive] = this.getPronouns(this.gender)

        let nominative2, accusative2, possessive2
        [nominative2, accusative2, possessive2] = this.getPronouns(this.gender2)        
        
        // TODO: the third party's name & gender?
        // DRIVER
        if (adjective_pair == 'fast-slow' && target_type == 'human') {
            this.target = 'driver'
            this.subject = `${capitalize(possessive2)} driving`
            this.common_context = `${this.name} is taking an Uber to the airport. ${capitalize(nominative)} wants the driver to drive `
            this.context2 = `Once ${nominative}'s made it to the gate, ${nominative} calls ${possessive} colleague, who ${nominative} was texting about ${possessive} issue during the Uber ride. ${this.name} says: `
        // ZEBRA
        } else if (adjective_pair == 'fast-slow' && target_type == 'thing') {
            this.target = 'zebra'
            this.subject = 'The '+ this.target
            this.common_context = `${this.name} is watching a zebra on a safari. ${capitalize(nominative)} wants the zebra to `
            this.context2 = `After the safari, ${nominative} calls ${possessive} colleague, who ${nominative} told about ${possessive} plans with the zebra. ${this.name} says: `
        // SPEECH
        } else if (adjective_pair == 'long-short' && target_type == 'human') {
            this.target = 'speech'
            this.subject = `${capitalize(possessive2)} ${this.target}`
            this.common_context = `A visitor is giving a speech at ${this.name}'s company. ${this.name} is `
            this.context2 = `After the speech, ${this.name} catches up with ${possessive} colleague, who ${nominative} previously told about ${possessive} expectations for the speech. ${this.name} says: `
        // TRAIL
        } else if (adjective_pair == 'long-short' && target_type == 'thing') {
            this.target = 'trail'
            this.subject = 'The '+ this.target
            this.common_context = `On Sunday, ${this.name} goes on an organized group hike. ${capitalize(nominative)} `
            this.context2 = `On Monday, ${this.name} runs into ${possessive} colleague, who ${nominative} told about ${possessive} feelings about the hike before the weekend, in the hallway. ${this.name} says: `
        // PARTY
        } else if (adjective_pair == 'big-small' && target_type == 'human') {
            this.target = 'party'
            this.subject = `${capitalize(possessive2)} ${this.target}`
            this.common_context = `${this.name2} invites ${this.name} to ${possessive2} party. ${this.name2} tells ${this.name} that ${nominative2} invited `
            this.context2 = `The next day, ${this.name} calls ${possessive} colleague, with whom ${nominative} shared ${possessive} expectations about the party. ${this.name} says: `
        // PLANT
        } else if (adjective_pair == 'big-small' && target_type == 'thing') {
            this.target = 'succulent'
            this.subject = 'The '+ this.target
            this.common_context = `${this.name} got a flower pot for ${possessive} birthday. ${capitalize(nominative)} buys a succulent online. ${capitalize(nominative)} wants it to be `
            this.context2 = `After the succulent arrives, ${nominative} calls ${possessive} colleague, who gave ${accusative} the flower pot. ${this.name} says: `
        // PRESENTATION
        } else if (adjective_pair == 'good-bad' && target_type == 'human') {
            this.target = 'presentation'
            this.subject = `${capitalize(possessive2)} ${this.target}`
            this.common_context = `${this.name2}, an intern who recently joined ${this.name}'s team, is giving a big presentation. ${this.name} `
            this.context2 = `After ${this.name2}'s presentation, ${this.name} meets ${possessive} colleague, who ${nominative} told about ${possessive} hopes for ${this.name2}'s presentation. ${this.name} says: `
        // WEATHER
        } else if (adjective_pair == 'good-bad' && target_type == 'thing') {
            this.target = 'weather'
            this.subject = 'The '+ this.target
            this.common_context = `${this.name} and ${possessive} friends are planning a picnic for Saturday. ${capitalize(nominative)} is `
            this.context2 = `After the weekend, ${this.name} sees ${possessive} colleague, who ${nominative} told about ${possessive} feelings about the picnic. ${this.name} says: `
        }
    }

    setDesired(adjective_pair, value) {
        const antonyms = adjective_pair.split("-");
        if (value == "normal") {
            this.desired = antonyms[0]
        } else if (value == "flipped") {
            this.desired = antonyms[1]
        }
    }

    setValueContext(adjective_pair, target_type, value) {
        let nominative, accusative, possessive
        [nominative, accusative, possessive] = this.getPronouns(this.gender)
        let nominative2, accusative2, possessive2
        [nominative2, accusative2, possessive2] = this.getPronouns(this.gender2)
        // DRIVER
        if (target_type == "human" && adjective_pair == "fast-slow" && value == "normal") {
            this.value_context = `fast because ${nominative} is late for a flight. `
        } else if (target_type == "human" && adjective_pair == "fast-slow" && value == "flipped") {
            this.value_context = `slowly because ${nominative} gets carsick. ` 
        // ZEBRA
        } else if (target_type == "thing" && adjective_pair == "fast-slow" && value == "normal") {
            this.value_context = `run fast so that ${nominative} can take a slo-mo video of it. `
        } else if (target_type == "thing" && adjective_pair == "fast-slow" && value == "flipped") {
            this.value_context = `walk slowly so that ${nominative} can draw a picture of it. `
        // SPEECH
        } else if (target_type == "human" && adjective_pair == "long-short" && value == "normal") {
            this.value_context = `interested in the topic, so ${nominative}'s hoping for a long speech. `
        } else if (target_type == "human" && adjective_pair == "long-short" && value == "flipped") {
            this.value_context = `not interested in the topic, so ${nominative}'s hoping for a short speech. ` 
        // TRAIL
        } else if (target_type == "thing" && adjective_pair == "long-short" && value == "normal") {
            this.value_context = `really enjoys hiking, so ${nominative} wants the trail to be long. `
        } else if (target_type == "thing" && adjective_pair == "long-short" && value == "flipped") {
            this.value_context = `doesn't enjoy hiking very much, so ${nominative} wants the trail to be short. `
        // PARTY
        } else if (target_type == "human" && adjective_pair == "big-small" && value == "normal") {
            this.value_context = `lots of people. ${(this.name)} says yes because ${nominative} likes big, crowded parties. `
        } else if (target_type == "human" && adjective_pair == "big-small" && value == "flipped") {
            this.value_context = `only a few people. ${(this.name)} says yes because ${nominative} likes small, intimate parties. ` 
        // PLANT
        } else if (target_type == "thing" && adjective_pair == "big-small" && value == "normal") {
            this.value_context = `big so that it fills the pot. `
        } else if (target_type == "thing" && adjective_pair == "big-small" && value == "flipped") {
            this.value_context = `small so that it fits the pot. `
        // PRESENTATION
        } else if (target_type == "human" && adjective_pair == "good-bad" && value == "normal") {
            this.value_context = `likes ${this.name2} and wants ${accusative2} to give a good presentation so ${this.name2} can get a full-time offer. `
        } else if (target_type == "human" && adjective_pair == "good-bad" && value == "flipped") {
            this.value_context = `dislikes ${this.name2} and wants ${accusative2} to give a bad presentation so ${this.name2} won't get a full-time offer. ` 
        // WEATHER
        } else if (target_type == "thing" && adjective_pair == "good-bad" && value == "normal") {
            this.value_context = `really looking forward to it, so ${nominative} wants the weather to be good. `
        } else if (target_type == "thing" && adjective_pair == "good-bad" && value == "flipped") {
            this.value_context = `hoping it will be canceled, so ${nominative} wants the weather to be bad. `
        }
    }
    
    setPolarity(adjective, adjective_pair) {
        const antonyms = adjective_pair.split("-");
        if (adjective == antonyms[0]) {
            this.polarity = "positive"
        } else if (adjective == antonyms[1]) {
            this.polarity = "negative"
        }
    }

    setPerson() {
        var names = _.shuffle([
                {"name":"James", "gender":"M"},
                {"name":"John", "gender":"M"},
                {"name":"Robert", "gender":"M"},
                {"name":"Michael", "gender":"M"},
                {"name":"William", "gender":"M"},
                {"name":"David", "gender":"M"},
                {"name":"Richard", "gender":"M"},
                {"name":"Joseph", "gender":"M"},
                {"name":"Charles", "gender":"M"},
                {"name":"Thomas", "gender":"M"},
                {"name":"Christopher", "gender":"M"},
                {"name":"Daniel", "gender":"M"},
                {"name":"Matthew", "gender":"M"},
                {"name":"Donald", "gender":"M"},
                {"name":"Anthony", "gender":"M"},
                {"name":"Paul", "gender":"M"},
                {"name":"Mark", "gender":"M"},
                {"name":"George", "gender":"M"},
                {"name":"Steven", "gender":"M"},
                {"name":"Kenneth", "gender":"M"},
                {"name":"Andrew", "gender":"M"},
                {"name":"Edward", "gender":"M"},
                {"name":"Joshua", "gender":"M"},
                {"name":"Brian", "gender":"M"},
                {"name":"Kevin", "gender":"M"},
                {"name":"Ronald", "gender":"M"},
                {"name":"Timothy", "gender":"M"},
                {"name":"Jason", "gender":"M"},
                {"name":"Jeffrey", "gender":"M"},
                {"name":"Gary", "gender":"M"},
                {"name":"Ryan", "gender":"M"},
                {"name":"Nicholas", "gender":"M"},
                {"name":"Eric", "gender":"M"},
                {"name":"Jacob", "gender":"M"},
                {"name":"Jonathan", "gender":"M"},
                {"name":"Larry", "gender":"M"},
                {"name":"Frank", "gender":"M"},
                {"name":"Scott", "gender":"M"},
                {"name":"Justin", "gender":"M"},
                {"name":"Brandon", "gender":"M"},
                {"name":"Raymond", "gender":"M"},
                {"name":"Gregory", "gender":"M"},
                {"name":"Samuel", "gender":"M"},
                {"name":"Benjamin", "gender":"M"},
                {"name":"Patrick", "gender":"M"},
                {"name":"Jack", "gender":"M"},
                {"name":"Dennis", "gender":"M"},
                {"name":"Jerry", "gender":"M"},
                {"name":"Alexander", "gender":"M"},
                {"name":"Tyler", "gender":"M"},
                {"name":"Mary", "gender":"F"},
                {"name":"Jennifer", "gender":"F"},
                {"name":"Elizabeth", "gender":"F"},
                {"name":"Linda", "gender":"F"},
                {"name":"Emily", "gender":"F"},
                {"name":"Susan", "gender":"F"},
                {"name":"Margaret", "gender":"F"},
                {"name":"Jessica", "gender":"F"},
                {"name":"Dorothy", "gender":"F"},
                {"name":"Sarah", "gender":"F"},
                {"name":"Karen", "gender":"F"},
                {"name":"Nancy", "gender":"F"},
                {"name":"Betty", "gender":"F"},
                {"name":"Lisa", "gender":"F"},
                {"name":"Sandra", "gender":"F"},
                {"name":"Helen", "gender":"F"},
                {"name":"Ashley", "gender":"F"},
                {"name":"Donna", "gender":"F"},
                {"name":"Kimberly", "gender":"F"},
                {"name":"Carol", "gender":"F"},
                {"name":"Michelle", "gender":"F"},
                {"name":"Emily", "gender":"F"},
                {"name":"Amanda", "gender":"F"},
                {"name":"Melissa", "gender":"F"},
                {"name":"Deborah", "gender":"F"},
                {"name":"Laura", "gender":"F"},
                {"name":"Stephanie", "gender":"F"},
                {"name":"Rebecca", "gender":"F"},
                {"name":"Sharon", "gender":"F"},
                {"name":"Cynthia", "gender":"F"},
                {"name":"Kathleen", "gender":"F"},
                {"name":"Ruth", "gender":"F"},
                {"name":"Anna", "gender":"F"},
                {"name":"Shirley", "gender":"F"},
                {"name":"Amy", "gender":"F"},
                {"name":"Angela", "gender":"F"},
                {"name":"Virginia", "gender":"F"},
                {"name":"Brenda", "gender":"F"},
                {"name":"Catherine", "gender":"F"},
                {"name":"Nicole", "gender":"F"},
                {"name":"Christina", "gender":"F"},
                {"name":"Janet", "gender":"F"},
                {"name":"Samantha", "gender":"F"},
                {"name":"Carolyn", "gender":"F"},
                {"name":"Rachel", "gender":"F"},
                {"name":"Heather", "gender":"F"},
                {"name":"Diane", "gender":"F"},
                {"name":"Joyce", "gender":"F"},
                {"name":"Julie", "gender":"F"},
                {"name":"Emma", "gender":"F"}
              ]);
        this.name = names[0].name
        this.gender = names[0].gender
        this.name2 = names[1].name
        this.gender2 = names[1].gender
    }

    setAttributeDependentOnAdjective(adjective) {
        if (adjective == "good" || adjective == "bad") {
            this.adjective_pair = "good-bad"
            this.property = "quality"
        }
        else if (adjective == "fast" || adjective == "slow") {
            this.adjective_pair = "fast-slow"
            this.property = "speed"
        }
        else if (adjective == "big" || adjective == "small") {
            this.adjective_pair = "big-small"
            this.property = "size"
        }
        else if (adjective == "long" || adjective == "short") {
            this.adjective_pair = "long-short"
            this.property = "length"
        }
    }

    setSentence(subject, negation, adjective) {
        var negation_string = "was"
        if (negation == 1) {
            negation_string = "wasn't"
        }
        this.sentence = `"${subject} ${negation_string} ${adjective}."`
    }    
}