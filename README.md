# OregonBigTree
A swift iOS app that interacts with Oregon Legislature API to display information about Measures and Legislators 


# Purpose

The goal of both the app and the webpage is to connect Oregonians to their local legislators and allow citizens 
to make sense of Oregon's legislative systems.  I want to make it easy for people to track state legislature and 
get their voices heard by their representatives.

# Current Functionalities

## 1.  Get representative information from address

OregonBigTree connects to the Google Civic Data API to return your state senator and representative, and their contact information,
including their phone number and e-mail.

## 2. Get information about measures that are about to be voted on.

OregonBigTree connects to the public Oregon Legislature API to display measures that will be voted on in the next few weeks. Each measure can be expanded
to show a measure summary, fiscal and revenue impacts, a timeline of all previous actions on the measure, and a link to the actual measure document.

## 3. Email Representatives

OregonBigTree provides a simple and intuitive interface to email state representatives.  Once a user discovers a measure they are passionate about,
they can press the "email senator/representative" buttons to bring up a form where they can easily type their reasoning for opposing/supporting
the bill.  Once they press "Submit Email", their device will pull up an preformatted message to be sent to their represenatative.  All the user has to do is press send.

## 4. View upcoming meetings ( limited )

The user is currently able to see the date and respective committee of all upcoming meetings.  Any meeting can be clicked on to show
all items on the agenda, including links to measures that are the topics of public hearings and work sessions.  I'm hoping to implement
a more intuitive calendar UI and links to the virtual public hearings in the future.

# Additional Note

The state senate and house are currently not in session, and the next session does not begin until next february.  For this reason
many "current-date" variables are hardcoded to march 1st.  This is to test the functionality of the upcoming measures and meetings features.
I plan to have this app in the app store before the next legislative session begins.
