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
    },

    exampleQ1ThumbVisible : function() {
      if ($("#exampleQ1").val() != 50); {
        $('#exampleQ1').addClass('visibleslider')
      };
    },

    exampleQ2ThumbVisible : function() {
      if ($("#exampleQ2").val() != 50); {
        $('#exampleQ2').addClass('visibleslider')
      };
    },

    exampleQ3ThumbVisible : function() {
      if ($("#exampleQ3").val() != 50); {
        $('#exampleQ3').addClass('visibleslider')
      };
    },

    // this is executed when the participant clicks the "Continue button"
    button: function() {
      // read in the value of the selected radio button
      this.exampleQ1Response = $("#exampleQ1").val();
      // check whether the participant selected a reasonable value (i.e, 5, 6, or 7)
      if (this.exampleQ1Response < "70") {
        // log response
        this.log_responses();
        // continue to next slide
        exp.go();
      } else {
        // participant gave non-reasonable response --> show error message
        $('.err').show(); // TODO: show error when not all questions are answered
        this.log_responses();
      }
    },

    log_responses: function() {
      // add response to exp.data_trials
      // this data will be submitted at the end of the experiment
      exp.data_trials.push({
        "slide_number_in_experiment": exp.phase,
        "id": "example1",
        "responseState": $("#exampleQ1").val(),
        "responseValue": $("#exampleQ2").val(),
        "responseIntention": $("#exampleQ3").val(),
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
    },

    exampleQ4ThumbVisible : function() {
      if ($("#exampleQ4").val() != 50); {
        $('#exampleQ4').addClass('visibleslider')
      };
    },

    exampleQ5ThumbVisible : function() {
      if ($("#exampleQ5").val() != 50); {
        $('#exampleQ5').addClass('visibleslider')
      };
    },

    exampleQ6ThumbVisible : function() {
      if ($("#exampleQ6").val() != 50); {
        $('#exampleQ6').addClass('visibleslider')
      };
    },

    // this is executed when the participant clicks the "Continue button"
    button: function() {
      // read in the value of the selected radio button
      this.exampleQ4Response = $("#exampleQ4").val();
      // check whether the participant selected a reasonable value (i.e, 5, 6, or 7)
      if (this.exampleQ4Response > "30") {
        // log response
        this.log_responses();
        // continue to next slide
        exp.go();
      } else {
        // participant gave non-reasonable response --> show error message
        $('.err').show(); // TODO: show error when not all questions are answered
        this.log_responses();
      }
    },

    log_responses: function() {
      // add response to exp.data_trials
      // this data will be submitted at the end of the experiment
      exp.data_trials.push({
        "slide_number_in_experiment": exp.phase,
        "id": "example2",
        "responseState": $("#exampleQ4").val(),
        "responseValue": $("#exampleQ5").val(),
        "responseIntention": $("#exampleQ6").val(),
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
      
      // var slider1 = document.getElementById("#q1Slider");
      // var slider2 = document.getElementById("#q2Slider");
      // var slider3 = document.getElementById("#q3Slider");
      // slider1.value = "50";
      // slider2.value = "50";
      // slider3.value = "50";

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
      var adjectives = stim.adjective.split('-');
      $("#context").html(stim.context);
      $("#sentence").html(stim.sentence);
      $("#q1").html(stim.questionState);
      $("#q2").html(stim.questionValue);
      $("#q3").html(stim.questionHonest); // TODO: I need to have 4 questions (intention -> honest, positive)
      $(".err").hide();

    },

    q1ThumbVisible : function() {
      if ($("#q1Slider").val() != 50); {
        $('#q1Slider').addClass('visibleslider')
      };
    },

    q2ThumbVisible : function() {
      if ($("#q2Slider").val() != 50); {
        $('#q2Slider').addClass('visibleslider')
      };
    },

    q3ThumbVisible : function() {
      if ($("#q3Slider").val() != 50); {
        $('#q3Slider').addClass('visibleslider')
      };
    },

    // handle click on "Continue" button
    button: function() {
      this.q1Response = $("#q1Slider").val();
      this.q2Response = $("#q2Slider").val();
      this.q3Response = $("#q3Slider").val();
      if (this.q1Response != "50" && this.q2Response != "50" && this.q3Response != "50") {
        this.log_responses();
        // exp.go();
        _stream.apply(this);
      } else {
        // did not answer all the questions
        $('.err').show();
        this.log_responses();
      }
    },

    log_responses: function() {
      // add response to exp.data_trials
      // this data will be submitted at the end of the experiment
      exp.data_trials.push({
        "slide_number_in_experiment": exp.phase,
        // "id": this.stim.TGrep,
        "responseState": $("#q1Slider").val(), // TODO: what is #?
        "responseValue": $("#q2Slider").val(),
        "responseIntention": $("#q3Slider").val(),
      });
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
  var stimuli = all_stims;

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
