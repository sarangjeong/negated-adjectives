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

function makeStimList() {
    var stims = [];
    for (let index = 0; index < adjectives.length; index++) { // this assumes length of adjectives & length of conditions are identical
      var adjective = adjectives[index]
      var [target_type, value, negation] = conditions[index]; // unpacking 
      var stim = Stim(adjective, target_type, value, negation).toDict() 
      stims.push(stim)
    }
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

        // Make stim
        this.setPerson()
        this.setAttributeDependentOnAdjective(this.adjective)
        this.setAttributeDependentOnAdjectivePairAndTargetType(this.adjective_pair, this.target_type)
        this.setPolarity(this.adjective, this.adjective_pair)

        this.setSentence(this.subject, this.negation, this.adjective)
        this.question.intention.instruction = `Think about ${this.name}'s intetion in saying "${this.sentence}".`
        this.setValueContext(this.adjective_pair, this.target_type, this.value)
        this.context1 = this.common_context + this.value_context

        this.question.state = `Based on what ${this.name} said, make your best guess: What was the ${this.property} of the ${this.target}?`
        this.question.value = `What ${this.property} does ${this.name} want the ${this.target} to have?`
        this.question.intention.honest = `How important was it to ${this.name} to be honest?`
        this.question.intention.positive = `How important was it to ${this.name} to be positive?`
    }
    
    toDict() {
        return {
            "adjective": this.adjective,
            "adjective_pair": this.adjective_pair,
            "polarity": this.polarity,
            "target_type": this.target_type, 
            "value": this.value, 
            "negation": this.negation, 
            "context1": this.context1, 
            "context2": this.context2,
            "sentence": this.sentence,
            "question": this.question
        }
    }

    setAttributeDependentOnAdjectivePairAndTargetType(adjective_pair, target_type) {
        let nominative, accusative, possessive
        [nominative, accusative, possessive] = this.getPronouns(this.gender)
        // TODO : write all if-conditions
        if (adjective_pair == 'fast-slow' && target_type == 'human') {
            this.subject = 'His driving'
            this.target = 'driver'
            this.common_context = `${this.name} is taking an Uber to the airport. ${capitalize(nominative)} wants the driver to drive `
            this.context2 = `Once ${nominative}'s made it to the gate, ${nominative} calls ${possessive} colleague, who ${nominative} was texting about ${possessive} issue during the Uber ride. ${this.name} says:`
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

    getPronouns(gender) {
        if (gender == "F") {
            return ["she", "her", "her"]
        } else if (gender == "M") {
            return ["he", "him", "his"]
        }
    }
    
    setValueContext(adj_pair, target_type, value) {
        // TODO : write all if-conditions
        if (target_type == "human" && adj_pair == "fast-slow" && value == "normal") {
            this.value_context = "fast because she is late for a flight"
        }
    }
    
    setSentence(subject, negation, adj) {
        var negation_string = "was"
        if (negation == 1) {
            negation_string = "wasn't"
        }
        this.sentence = `${subject} ${negation_string} ${adj}.`
    }    
}