 // Advanced Databases
 // Developed by: Eryk Szlachetka
 // Student number: C14386641

db.students.insert({
	_id : 1,
	name: 'mary',
	surname: 'murray',
	age: 45,
	nationality: 'irish',
	course: [ {
			name: "database",
			credits: 10,
			date : "10/10/2011",
			mark : 56
		},
		{
			name: "maths",
			credits: 5,
			date : "09/11/2012",
			mark : 76
		},
		{
			name: "programming",
			credits: 15,
			date : "02/07/2014",
			mark : 45
		}
	]
});

db.students.insert({
    _id : 2,
	name: 'bill',
	surname: 'bellichick',
	qge: 32,
	nationality: 'american',
	course: [ {
			name: "database",
			credits: 10,
			date : "10/10/2011",
			mark : 55
		},
		{
			name: "maths",
			credits: 5,
			date : "09/11/2012",
			mark : 87
		},
		{
			name: "programming",
			credits: 15,
			date : "10/10/2011",
			mark : 45
		}
	]
});
db.students.insert({
    _id : 3,
	first: 'tom',
	last: 'brady',
	age: 22,
	nationality: 'canadian',
	course: [ {
			name: "database",
			credits: 10,
			date : "09/11/2012",
			mark : 34
		},
		{
			name: "maths",
			credits: 5,
			date : "02/07/2014",
			mark : 56
		}
	]
});
db.students.insert({
    _id : 4,
	first: 'john',
	last: 'bale',
	age: 24,
	nationality: 'english',
	course: [ {
			name: "database",
			credits: 10,
			date : "10/10/2011",
			mark : 71
		},
		{
			name: "maths",
			credits: 5,
			date : "10/10/2011",
			mark : 88
		},
		{
			name: "programming",
			credits: 15,
			date : "09/11/2012",
			mark : 95
		}
	]
});


// --------------------------------------- Question 1 ---------------------------------------
db.students.find({course: {$elemMatch: {mark: {'$lt':40} }}});
db.students.aggregate([
	{
		$unwind : "$course"
	},
	{
		$lt : 40
	},
	{
		$out : "students_failed"
	}
]);

// --------------------------------------- Question 2 ---------------------------------------
db.students.find({course: {$elemMatch: {mark: {'$gte':40}  }}});
db.students.aggregate([
	{
		$unwind : "$course"
	},
	{
		$gte : 40
	},
	{
		$out : "students_passed"
        
	}
]);

db.students_passed.count();

// --------------------------------------- Question 3 ---------------------------------------

db.students.aggregate([
    { $unwind: "$course" },
    { $group : { _id: "$_id", 
                avgAge : {  
                    $avg : "$course.mark" }, 
                    max : 
                        {  
                            $max : "$course.mark" 
                        } 
               } 
    }
]);
