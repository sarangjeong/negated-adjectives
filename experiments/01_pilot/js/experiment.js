// set up experiment logic for each slide
function make_slides(f) {
  var slides = {};

  // set up initial slide
  slides.i0 = slide({
    name: "i0",
    start: function() {
      exp.startT = Date.now();
    }
  });

  // set up the first example slide
  slides.example1 = slide({
    name: "example1",

    // this is executed when the slide is shown
    start: function() {
      // hide error message
      $('.err').hide(); 
      $('.attention_state').hide();
      $('.attention_value').hide();
      $(".state").hide(); 
      $(".positive").hide();
      $(".honest").hide();
      $(".context2").hide();
      $(".sentence").hide();
      $(".intention").hide();
    },

    valueOnClick : function() {
      if ($("#example1ValueSlider").val() != 50); {
        $('#example1ValueSlider').addClass('visibleslider')
        $(".context2").show();
        $(".sentence").show();
        $(".state").show();
        // don't allow modifying slider
        var slider = document.getElementById("example1ValueSlider");
        slider.disabled = true; 
      };
    },

    stateOnClick : function() {
      if ($("#example1StateSlider").val() != 50); {
        $('#example1StateSlider').addClass('visibleslider')
        $(".intention").show();
        $(".honest").show();
        $(".positive").show();
      };
    },

    honestOnClick : function() {
      if ($("#example1HonestSlider").val() != 50); {
        $('#example1HonestSlider').addClass('visibleslider')
      };
    },

    positiveOnClick : function() {
      if ($("#example1PositiveSlider").val() != 50); {
        $('#example1PositiveSlider').addClass('visibleslider')
      };
    },

    // this is executed when the participant clicks the "Continue button"
    button: function() {
      let stateStatus = document.getElementById('example1StateSlider');
      let valueStatus = document.getElementById('example1ValueSlider');
      let honestStatus = document.getElementById('example1HonestSlider');
      let positiveStatus = document.getElementById('example1PositiveSlider'); 

      // read in the value of the selected radio button
      this.stateResponse = $("#example1StateSlider").val();
      this.valueResponse = $("#example1ValueSlider").val();

      // check whether the participant responded to every question
      if (stateStatus.className != 'slider visibleslider' || valueStatus.className != 'slider visibleslider' || honestStatus.className != 'slider visibleslider' || positiveStatus.className != 'slider visibleslider') { 
        $('.err').show();
        this.log_responses();
      // check whether the participant selected a reasonable value 
    } else if (this.valueResponse > "50") {
      // participant gave non-reasonable response --> show error message
      $('.err').hide();
      $('.attention_value').show(); 
      this.log_responses();
    } else if (this.stateResponse < "50") {
        // participant gave non-reasonable response --> show error message
        $('.err').hide();
        $('.attention_value').hide(); 
        $('.attention_state').show(); 
        this.log_responses();
      } else {
        // log response
        this.log_responses();
        // continue to next slide
        exp.go();
      }
    },

    log_responses: function() {
      // add response to exp.data_trials
      // this data will be submitted at the end of the experiment
      exp.data_trials.push({
        "slide_number_in_experiment": exp.phase,
        "stimulusType": "example1",
        "responseState": $("#example1StateSlider").val(),
        "responseValue": $("#example1ValueSlider").val(),
        "responseHonest": $("#example1HonestSlider").val(),
        "responsePositive": $("#example1PositiveSlider").val(),
        // record more data
        "speakerName": "Jane",
        "speakerGender": "F", 
        "adjective": "quiet",
        "adjectivePair": "talkative-quiet",
        "polarity": "negative",
        "negation": "1",
        // record more data so that I read off of json what item it is
        "sentence": "\"My date wasn't quiet.\"", 
        "targetType": "human",
        "item": "date",
        "desired": "quiet",
        "value": "flipped"
      });
    },
  });

  // set up slide for second example trial
  slides.example2 = slide({
    name: "example2",

    // this is executed when the slide is shown
    start: function() {
      // hide error message
      $('.err').hide();
      $('.attention_state').hide();
      $('.attention_value').hide();
      $(".state").hide(); 
      $(".positive").hide();
      $(".honest").hide();
      $(".context2").hide();
      $(".sentence").hide();
      $(".intention").hide();
    },

    stateOnClick : function() {
      if ($("#example2StateSlider").val() != 50); {
        $('#example2StateSlider').addClass('visibleslider')
        $(".intention").show();
        $(".honest").show();
        $(".positive").show();
      };
    },

    valueOnClick : function() {
      if ($("#example2ValueSlider").val() != 50); {
        $('#example2ValueSlider').addClass('visibleslider')
        $(".context2").show();
        $(".sentence").show();
        $(".state").show();
      };
    },

    honestOnClick : function() {
      if ($("#example2HonestSlider").val() != 50); {
        $('#example2HonestSlider').addClass('visibleslider')
      };
    },

    positiveOnClick : function() {
      if ($("#example2PositiveSlider").val() != 50); {
        $('#example2PositiveSlider').addClass('visibleslider')
      };
    },
    
    // this is executed when the participant clicks the "Continue button"
    button: function() {
      let stateStatus = document.getElementById('example2StateSlider');
      let valueStatus = document.getElementById('example2ValueSlider');
      let honestStatus = document.getElementById('example2HonestSlider');
      let positiveStatus = document.getElementById('example2PositiveSlider'); 

      // read in the value of the selected radio button
      this.stateResponse = $("#example2StateSlider").val();
      this.valueResponse = $("#example2ValueSlider").val();

      // check whether the participant responded to every question
      if (stateStatus.className != 'slider visibleslider' || valueStatus.className != 'slider visibleslider' || honestStatus.className != 'slider visibleslider' || positiveStatus.className != 'slider visibleslider') { 
        $('.err').show();
        this.log_responses();
      // TODO : attention check is not working for example 1 & 2
      // check whether the participant selected a reasonable value 
    } else if (this.valueResponse < "50") {
      // participant gave non-reasonable response --> show error message
      $('.err').hide();
      $('.attention_value').show(); 
      this.log_responses();
    } else if (this.stateResponse < "50") {
        // participant gave non-reasonable response --> show error message
        $('.err').hide();
        $('.attention_value').hide(); 
        $('.attention_state').show(); 
        this.log_responses();
    } else {
        // log response
        this.log_responses();
        // continue to next slide
        exp.go();
      }
    },

    log_responses: function() {
      // add response to exp.data_trials
      // this data will be submitted at the end of the experiment
      exp.data_trials.push({
        "slide_number_in_experiment": exp.phase,
        "stimulusType": "example2",
        "responseState": $("#example2StateSlider").val(),
        "responseValue": $("#example2ValueSlider").val(),
        "responseHonest": $("#example2HonestSlider").val(),
        "responsePositive": $("#example2PositiveSlider").val(),
        // record more data
        "speakerName": "Tom",
        "speakerGender": "M", 
        "adjective": "talkative",
        "adjectivePair": "talkative-quiet",
        "polarity": "positive",
        "negation": "0",
        // record more data so that I read off of json what item it is
        "sentence": "\"My date was talkative.\"", 
        "targetType": "human",
        "item": "date",
        "desired": "talkative",
        "value": "normal"
      });
    },
  });

  // set up slide with instructions for main experiment
  slides.startExp = slide({
    name: "startExp",
    start: function() {
    },
    button: function() {
      exp.go(); //use exp.go() if and only if there is no "present" data.
    },
  });

  slides.trial = slide({
    name: "trial",

    // start: function() {
    //   var stim = {
    //     "adjective": "fast-slow",
    //     "polarity": "pos",
    //     "target": "human",
    //     "value": "flip",
    //     "negation": "1",
    //     "context": "Jane is taking an Uber to the airport. She wants the driver to drive slowly because she gets carsick. Once she's gotten off the Uber, she calls her colleague, who she was texting about her issue during the Uber ride. Jane says: ", 
    //     "sentence": "His driving wasn't fast.",
    //     "questionState": "What was the speed of the Uber driver?",
    //     "questionValue": "What speed did Jane want the Uber driver to have?",
    //     "questionIntention": "What was Jane's intention for saying 'His driving wasn't fast'?",
    //   }   
    // The  lines above from "start:..." to the end of var stim = {...}" define a placeholder stimulus that you will have to delete when
    // loading in the individual stimulus data. 

    // To rotate through stimulus list, comment out the above lines and  uncomment the following 2:
    present: exp.stimuli,
    present_handle : function(stim) {

      // unselect all radio buttons at the beginning of each trial
      // (by default, the selection of the radio persists across trials)
      // $("input[name='number']:checked").prop("checked", false);
      // $("#check-strange").prop("checked", false);

      // reset sliders
      $("input[name='number']:checked").prop("checked", false);
      
      document.getElementById("q1Slider").value = "50";
      document.getElementById("q2Slider").value = "50";
      document.getElementById("q3Slider").value = "50";
      document.getElementById("q4Slider").value = "50";
      // TODO : reset disabled more efficiently
      document.getElementById("q1Slider").disabled = false;
      document.getElementById("q2Slider").disabled = false;
      document.getElementById("q3Slider").disabled = false;
      document.getElementById("q4Slider").disabled = false;
      $('#q1Slider').removeClass('visibleslider')
      $('#q2Slider').removeClass('visibleslider')
      $('#q3Slider').removeClass('visibleslider')
      $('#q4Slider').removeClass('visibleslider')

      // store stimulus data
      this.stim = stim;

      //handle display of context 
      // if (exp.condition == "context") {
      //   // extract context data
      //   var contexthtml = stim.Context;
      //   // reformat the speaker information for context
      //   contexthtml = contexthtml.replace(/Speaker A:/g, "<b>Speaker #1:</b>");
      //   contexthtml = contexthtml.replace(/Speaker B:/g, "<b>Speaker #2:</b>");
      //   $(".case").html(contexthtml);
      // } else {
      //   var contexthtml = "";
      //   $(".case").html(contexthtml);
      // }

      // replace the placeholder in the HTML document with the relevant sentences for this trial
      var adjectives = stim.adjective_pair.split('-');
      
      $("#context1").html(stim.context1);
      $("#context2").html(stim.context2);
      $("#sentence").html(stim.sentence);
      $("#adjPos1").html(adjectives[0]);
      $("#adjNeg1").html(adjectives[1]); 
      $("#adjPos2").html(adjectives[0]);
      $("#adjNeg2").html(adjectives[1]); 
      console.log(stim.type)
      if (stim.type == "control") {
        console.log("This is control")
        $("#q1").html(stim.question.state); 
        $("#q2").html(stim.question.value);
      } else {
        $("#q1").html(stim.question.value); 
        $("#q2").html(stim.question.state);
      }
      $('#intention').html(stim.question.intention.instruction);
      $("#q3").html(stim.question.intention.honest); 
      $("#q4").html(stim.question.intention.positive);
      $(".err").hide();
      // hide questions
      $("#q2").hide(); // TODO: rename q1 - q3 to qState etc (their positions changed)
      $("#q2Slider").hide();
      $("#q3").hide();
      $("#q3Slider").hide();
      $("#q4").hide();
      $("#q4Slider").hide();
      $("#endpoint2-1").hide();
      $("#endpoint2-2").hide();
      $("#endpoint3-1").hide();
      $("#endpoint3-2").hide();
      $("#endpoint4-1").hide();
      $("#endpoint4-2").hide();
      $("#context2").hide();
      $("#sentence").hide();
      $("#intention").hide();
    },

    // show questions sequentially
    
    q1ThumbVisible : function() {
      if ($("#q1Slider").val() != 50); {
        $('#q1Slider').addClass('visibleslider')

        // don't allow modifying slider
        var slider = document.getElementById("q1Slider");
        slider.disabled = true; 

        $("#q2").show();
        $("#q2Slider").show();
        $("#endpoint2-1").show();
        $("#endpoint2-2").show();
        $("#context2").show();
        $("#sentence").show();
      };
    },

    q2ThumbVisible : function() {
      if ($("#q2Slider").val() != 50); {
        $('#q2Slider').addClass('visibleslider')

        // don't allow modifying slider
        var slider = document.getElementById("q2Slider");
        slider.disabled = true; 

        $("#intention").show();
        $("#q3").show();
        $("#q3Slider").show();  
        $("#endpoint3-1").show();
        $("#endpoint3-2").show();
        $("#q4").show();
        $("#q4Slider").show();  
        $("#endpoint4-1").show();
        $("#endpoint4-2").show();
      };
    },

    q3ThumbVisible : function() {
      if ($("#q3Slider").val() != 50); {
        $('#q3Slider').addClass('visibleslider')
        
        // don't allow modifying slider
        var slider = document.getElementById("q3Slider");
        slider.disabled = true; 
      };
    },

    q4ThumbVisible : function() {
      if ($("#q4Slider").val() != 50); {
        $('#q4Slider').addClass('visibleslider')

        // don't allow modifying slider
        var slider = document.getElementById("q4Slider");
        slider.disabled = true; 
      };
    },

    // handle click on "Continue" button
    button: function() {      
      let q1Status = document.getElementById('q1Slider');
      let q2Status = document.getElementById('q2Slider');
      let q3Status = document.getElementById('q3Slider');
      let q4Status = document.getElementById('q4Slider');
        // did not answer all the questions
        if (q1Status.className != 'slider visibleslider' || q2Status.className != 'slider visibleslider' || q3Status.className != 'slider visibleslider' || q4Status.className != 'slider visibleslider') {
        $('.err').show();
        this.log_responses();
        // exp.go();
      } else {
        this.log_responses(); // this (logging) must come before _stream (reset)
        _stream.apply(this);
      }
    },

    log_responses: function() {
      // add response to exp.data_trials
      // this data will be submitted at the end of the experiment
      
      if (this.stim.type == "control") {
        exp.data_trials.push({
          "slide_number_in_experiment": exp.phase,
          "stimulusType": this.stim.type,
          "responseState": $("#q1Slider").val(), // difference
          "responseValue": $("#q2Slider").val(), // difference
          "responseHonest": $("#q3Slider").val(),
          "responsePositive": $("#q4Slider").val(),
          "speakerName": this.stim.name,
          "speakerGender": this.stim.gender, 
          "adjective": this.stim.adjective,
          "adjectivePair": this.stim.adjective_pair,
          "polarity": this.stim.polarity,
          "negation": this.stim.negation,
          // TODO: record more data so that I read off of json what item it is
          "sentence": this.stim.sentence, 
          "targetType": this.stim.target_type,
          "item": this.stim.item,
          "desired": this.stim.desired, 
          "value": this.stim.value, 
          "state": this.stim.state 
        }); 
      } 
      else {
        exp.data_trials.push({
          "slide_number_in_experiment": exp.phase,
          "stimulusType": this.stim.type,
          "responseValue": $("#q1Slider").val(), // difference
          "responseState": $("#q2Slider").val(), // difference
          "responseHonest": $("#q3Slider").val(),
          "responsePositive": $("#q4Slider").val(),
          "speakerName": this.stim.name,
          "speakerGender": this.stim.gender, 
          "adjective": this.stim.adjective,
          "adjectivePair": this.stim.adjective_pair,
          "polarity": this.stim.polarity,
          "negation": this.stim.negation,
          // record more data so that I read off of json what item it is
          "sentence": this.stim.sentence, 
          "targetType": this.stim.target_type,
          "item": this.stim.item,
          "desired": this.stim.desired,
          "value": this.stim.value,
          "state": this.stim.state 
        }); 
      }
    },
  });

  // slide to collect subject information
  slides.subj_info = slide({
    name: "subj_info",
    submit: function(e) {
      exp.subj_data = {
        language: $("#language").val(),
        enjoyment: $("#enjoyment").val(),
        asses: $('input[name="assess"]:checked').val(),
        age: $("#age").val(),
        gender: $("#gender").val(),
        education: $("#education").val(),
        fairprice: $("#fairprice").val(),
        comments: $("#comments").val()
      };
      exp.go(); //use exp.go() if and only if there is no "present" data.
    }
  });

  // 
  slides.thanks = slide({
    name: "thanks",
    start: function() {
      exp.data = {
        "trials": exp.data_trials,
        "catch_trials": exp.catch_trials,
        "system": exp.system,
        "condition": exp.condition,
        "subject_information": exp.subj_data,
        "time_in_minutes": (Date.now() - exp.startT) / 60000
      };
      proliferate.submit(exp.data);
    }
  });

  return slides;
}

/// initialize experiment
function init() {

  exp.trials = [];
  exp.catch_trials = [];
  var stimuli = makeStimList();

  exp.stimuli = stimuli; //call _.shuffle(stimuli) to randomize the order;
  exp.n_trials = exp.stimuli.length;

  // exp.condition = _.sample(["context", "no-context"]); //can randomize between subjects conditions here
  
  exp.system = {
    Browser: BrowserDetect.browser,
    OS: BrowserDetect.OS,
    screenH: screen.height,
    screenUH: exp.height,
    screenW: screen.width,
    screenUW: exp.width
  };

  //blocks of the experiment:
  exp.structure = [
    "i0",
    "example1",
    "example2",
    "startExp",
    "trial",
    "subj_info",
    "thanks"
  ];

  exp.data_trials = [];

  //make corresponding slides:
  exp.slides = make_slides(exp);

  exp.nQs = utils.get_exp_length();
  //this does not work if there are stacks of stims (but does work for an experiment with this structure)
  //relies on structure and slides being defined

  $('.slide').hide(); //hide everything

  $("#start_button").click(function() {
    exp.go();
  });

  exp.go(); //show first slide
}
