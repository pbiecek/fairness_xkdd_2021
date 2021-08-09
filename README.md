# Explaining and Checking Fairness for Predictive Models

Tutorial at 3rd Workshop [eXplaining Knowledge Discovery in Data Mining](https://kdd.isti.cnr.it/xkdd2021/)

by [Przemysław Biecek](https://github.com/pbiecek)

Link to this page: https://tinyurl.com/xkdd-fairness

Slides: [fairness_xkdd_2021.pdf](https://github.com/pbiecek/fairness_xkdd_2021/blob/main/fairness_xkdd_2021.pdf)

Sources for fairmodels and arena: [fairness_with_fairmodels.R](https://github.com/pbiecek/fairness_xkdd_2021/blob/main/fairness_with_fairmodels.R)


## Part 1

Good morning.
My name is Przemysław Biecek, and today I will give a tutorial related to fairness in machine learning.
I am a leader of the MI2 Data Lab at Warsaw University of Technology. My group works on methods and tools and good practices for explanatory model analysis. In the last part of the tutorial, I will show the fairmodels package that we created.

The title of the tutorial is 'Explaining and Checking Fairness for Predictive Models', and the tutorial is divided into three parts.
First, I will talk about fairness in general. Do we have a problem with discrimination, and which areas are affected by it?
The second part is related to fairness measures. We will discuss the most common statistics for the detection of discrimination.
The third part will be the hands-on presentation of software that helps to check and visualize fairness.

Ready? Let's go.

---

Fairness is a hot topic nowadays. But is it possible that algorithms discriminate?
It turns out that we have a large and growing list of examples for that. 

---

To show a few.
ProPublica published an article in which they describe an ad campaign in social media that was not targeted to any specific population, but for some reason, the recommendation system decided to show it mostly to male users. Blue bars stand for the number of male viewers, while the green one is for females. And even though truck drivers are primarily male, the company said that they would be more than happy to accept any qualified driver despite the gender.

---

Another example of gender discrimination is a recommendation system build for supporting resume screening. 
Even though Amazon has a higher fraction of female employees than other IT companies, the system trained on historical data learned very subtle artefacts that are proxy for gender. The project was stopped as it was not possible to remove the bias completely.

---

One does not need a fancy AI system to suffer from some sort of bias. A viral Twitter video showed that the soap dispenser was not working correctly for too dark skin. Even though the system is probably simple, it was not calibrated properly.

---

And just to add one more example to this, the wired magazine described an example of a robot beauty contest that was trained on the biased sample and was later accused of being racist.

---

The list of problems with discrimination is much longer and covered in many books and articles. The book that I like the most is the bestseller 'Weapons of math destruction' by Cathy O'Neil. 
As she points out, many of these problems result from a lack of scepticism. Systems are being used without proper validation. 
And I agree with this. When we build an AI system, we need to be very sceptical and proactively look for potential problems in every possible direction.
So rest of this tutorial will be related to the tools and protocols for proper validation of predictive models.

---

So what kind of problems should we look for?
What does it mean to discriminate?

---

It is not a simple question, and the answer may vary in different countries or cultures.
But since we are in Europe, I will refer to the 'Handbook on European non-discrimination law'. This version was published in 2018.

This is very interesting literature on various legal aspects of discrimination. You can find a lot of interesting use-case in it, definitely worth reading. 
It is written from a legal perspective,

What will be important for us is the definition of discrimination, which is a situation in which one group, defined by a certain sensitive attribute, is treated worse than another group.
So the crucial part of this definition is that different treatment leads to some sort of harm.

---

In this document, there is a list of sensitive attributes that should not be the cause of inferior treatment. 
In this list, we see attributes such as gender, age, race, religion which are protected in most legal systems.
In this book, for each attribute, you will find a few pages long discussion and examples of discriminative treatment.

---

It's worth noting, however, that the list of protected attributes will vary between jurisdictions and application domains. This slide is from a great workshop about fairness by Moritz Hardt, which was more focused on US law. We see in this list attributes that were not mentioned in the European list, such as pregnancy status, veteran status or genetic information.
So it is important to remember that the list of protected attributes may be different in different cultures.

Despite these differences, it is worth remembering the definition that a fair model shall not harm a protected group.

---

While the intent is clear and hard to disagree with, there is still no single approach defining how to guarantee fairness. It is still a hot area of research both in academia and with many business applications. In fact, every major predictive modelling company lists fairness as one of the key elements of its solutions.

Here you see screenshots from webpages of H2O, Tensorflow, IBM or PWC. Fairness is listed everywhere.

---

The checking for fairness is complicated by the fact that discrimination does not mean that we treat people differently. We cannot treat them worse.

---

This is an important difference and is very interestingly presented in the article "Sex and gender differences and biases in artificial intelligence for biomedicine and healthcare".
The paper discusses various forms of differential treatment of patients of a different gender.
We will find here a distinction between differences or biases that have a positive effect and those that have a negative impact.
Examples of undesirable bias include different treatment due to stigmatization or belonging to an underrepresented sample/minority. But it is also important to note that there are many reasons to treat people of different genders differently if it leads to their benefit. This is a so-called desirable bias. Certain therapies may be more or less effective depending on gender. It is to say that the difference needs to be well understood to allow for desirable bias, not undesirable one.

---

Here is a table from this paper showing where the scientific literature speaks of the need for differential treatment between the genders, although unfortunately, in today's practice, these differences are not taken into account.

Let's look at an example of cardiovascular disorders. Despite known differences in response to various forms of treatment, diagnostic procedures do not take some of these differences into account. Gender-specific prescribing of drugs such as statins or beta-blockers could increase the benefit of treatment.

Although CDC is the leading cause of death among women, clinical trials mostly recruit men. Which further raises the risk of a poorer assessment of treatment efficacy for women.

Thus, we see that the fairness of the model is not about ignoring differences between protected groups but about conscious avoiding situations that harm unprivileged groups.

---

Where might a discrimination problem arise?
If we want to analyze models critically, we need to know which aspects to look at more closely.

There are many possible sources of bias. Let us look at the most common.

---

The first source is a matter of historical treatment.

The data on which we train models are always collected in the past and may have encoded differences in treatment that should be avoided in the future. 
Even if the perfectly collected data is an accurate representation of past people's behaviours, these behaviours may be discriminatory. 
For example, think about the different treatment of women in the labour market. 

---

Another reason for discrimination is the representativeness of the data. Data collection is often a costly and tedious process, and it may be the case that the data collected are not fully representative of the population as a whole. 
An example is the collection of covid sequence data in the GISAID database, as the sequencing of samples is expensive. In this open database, you will find data mostly from developed European countries, and the representation of the covid genetic variability in other countries is much worse.
Another example is the crime statistics collected by the police. If the police are mainly directed to neighbourhoods where crime has historically been higher, the crimes in such neighbourhoods will have a high detection rate because more police officers will follow it. 

---

Another potential cause of discrimination is the situation in which we are interested in a variable that is difficult to measure and whose measurement may be distorted by some other characteristic associated with the protected attribute.
Think, for example, about skills assessments such as math tests in the PISA programme. If these tests contain a lot of descriptive tasks, then they may have worse results in immigrant families with less knowledge of the language of the test. If they are administered on a computer, then they may discriminate against poorer families who do not have frequent access to a computer. In the case of the PISA data, there are many protocols for tracking such discrimination for variables that are tricky to measure.

---

Discrimination can also occur if an algorithm is evaluated on a not well-represented population.
This may falsely increase the perception that an algorithm works well, when in fact, it may work well on a privileged group and not on a minority.

---

There are more examples like this, so please remember that fairness is not a problem with a single solution.

---

The bias can occur everywhere.

This diagram describes the typical life cycle of a prediction model from experiment design and data collection through modelling and model deployment.

---

In each of these stages, we may have to deal with some sort of bias, and at each element, it is worth to consider what consequences for the whole process have decisions made at that stage.
Taking care of the model's fairness means not only adding one metric to evaluate the model but also constantly caring for the social consequences of the developed and implemented solution.
And often, bias occurs in the most obvious places.

---

An interesting example is the StreetBumps project. 
The city of Boston released an application for mobile phones that allows identifying potholes based on vibrations measured by an accelerometer. 
It is a very innovative idea, but when analyzing such data, one has to take into account the representativeness of the collected data. 
Much more information about potholes will come from the neighbourhoods where wealthier and younger people live, who use mobile phones more often.

You will find a deeper discussion about this problem in the Hidden Biases n Big Data article by Kate Crawford.

---

Another very interesting source of bias is biased data representations.
In machine learning, especially in deep learning, it is very popular to use object embeddings, whether it is text embeddings or image embeddings. You can embed anything.

---

It turns out that such embeddings can also be skewed in terms of representations.
There is a lot of literature on this subject. 
For example, text generating systems autocomplete differently phrases that start with "He is" or "She is".
As expected, embedding words contain statistical relationships related to the frequency of occurrence in historical data.
However, when these associations are used to generate text, they can be very blatant. 
In the case of association with occupations, there is additionally the issue of occupational prestige, where not only gender is associated with different occupations, but also with occupations of different prestige.

---

Today, bias detection and removal from text embedding is a separate and very active field.

---

Just to add one more dimension to this problem. 
It is common to think that discriminated groups get lower scores by the predictive model. 

---

And sometimes, this is true, as in the example of the resume screening bot. The scores for male candidates were higher than scores for female candidates due to some biases.

---

But the Gender Shades study show that discrimination may be linked with poorer performance. Here the problem is not that some people are more frequently detected as white males, but the problem is that the face recognition system has different performances in different groups.
And the worst performance it exhibits in the dark female group.
This is a great article definitely worth reading.

---

It is also important to realize that lower performance can generate some problems in future and can lead to increased discrimination in the future.
Think about credit scoring. 
If in group A credits are admitted with high accuracy, and in group B, credits are admitted randomly, then over time, we will get a dataset where in group A, credits are paid on time while in group B they are frequently not paid. So the perception will be that in group B the credit behaviour is worse.
This is only because the positive credit decision was assigned in group B were more random.

---

A common misconception is that to assure fairness, one should ignore the features related to the protected attribute. But the opposite is true. To assure fairness, the protected attributes shall be taken into account to monitor if fairness criteria are satisfied.

---

Think about the Apple card example. This product was accused of gender discrimination because even in a family with the same account, one can see differences in credit lines. And there was no way to check what influenced these differences, so natural accusation leads to gender.
Goldman Sachs, which prepared this algorithm, claims that it does not use gender for predictions. 

---

But this is exactly the problem because the fairness criteria were not monitored during the system application.

---

In a minute, I will show you how we can detect and measure fairness. But remember that is it tricky to be too much focused on these criteria as they are only to support model development. 

---

Many recent papers show that such criteria can be easily gamed if our only goal is to satisfy some group fairness statistics.
There is a true risk of 'fairwashing', which is not how we shall think about fairness.

---

I hope you are warned.
So let's see the most common fairness measures.


