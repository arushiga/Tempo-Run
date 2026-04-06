# Tempo iOS

CIS 5120 - Assignment 5 Implementation Prototype

## Stack
- Swift
- SwiftUI
- Firebase (Auth + Firestore)

## Setup
1. Clone repo
2. Open `Tempo.xcodeproj`
3. Run on iPhone simulator

## Current Features
- Hello World
- Hello Styles
- App shell (in progress)




# README.md --- use the below text as assignment instructions and technical requirements that we as a team laid out

## [Tempo] A5 Technical Requirements

### Required:
- “Hello world” app. You create an extremely simple app that displays “Hello world” in the programming language and UI framework that you have chosen to use.
- “Hello styles.” You implement one example of everything from your style guide (each font, color, icon) using the styling languages / libraries that you have chosen

---

### Additional Technical Requirements:
- Firestore/Firebase backend setup to store the following:
  - Authentication profiles / regular user profiles
  - Training plans
  - Past runs organized by time
  - Users’ friends/connections
- Login Functionality: enable signup and login functionality for users to store their information
- Weekly Run Planner: Implement front end drag-drop functionality for the run planning training page
- Map Interface: Core Location and MapKit / MapKit for SwiftUI integration with the activities page to allow visualization of individual runs, activated by the record button (Optional)

---

### List of Requirements:

#### 1. “Hello World” App
Our team will create a one-screen iOS app in SwiftUI that displays “Hello World” and runs successfully on an iPhone simulator or physical iPhone.

#### 2. “Hello styles”
We will create a SwiftUI screen that renders one example of each core style-guide element used in Tempo, including our selected colors, typography styles, and icons. We will create a cohesive color theme that will contain two primary colors and one accent color. Based on these design decisions, representative icons will be selected for the core scheduling functionality.

#### 3. Login Functionality
Our team will create a sign-up and login landing page on the mobile app that will allow users to create an account and login. This will be supported by a Firestore/Firebase backend setup to store user information and application data.

#### 4. Profile Data Rending
Our team will develop a profile page that will show a users’ friends and past activities organized by date by fetching and displaying information from Firestore. Users will be able to see their progress on past training plans visualized by a progress bar for each historical training plan.

#### 5. Training Scheduling Tool – Drag and Drop Functionality
Our team will build the drag and drop functionality on the training plan page and show that users can drag and drop one icon into each square. Each planner cell will accept at most one workout and reflect the training intensity and activity category via the icon design.

---

## Assignment 5: Implementation Prototypes

### Due date and submission on Gradescope.

By the end of the semester, you need to have a polished, tested, and fully-functional version of your user interface. Until now, you have worked on designing your UI. But now you need to work on implementing a functioning UI that lives up to your vision. Unlike prior assignments, which developed the role and look and feel aspects of your interface, this assignment focuses entirely on implementation.

---

## Goal

The output of this assignment is a set of runnable code snippets and outputs that show you (and us) that you can do everything that your UI needs to do. More concretely, you will provide a set of technical requirements, code repositories that implement your requirements, and snippets of outputs that show you met those requirements.

This assignment is our major chance to make sure your project is on track. Final projects are due a little over two weeks after A5 is submitted. Give this assignment your best to make sure that you have removed as much uncertainty from your project as possible.

---

## Expectations

You have flexibility in how you do this assignment. We require this minimal structure so that we can support your work as mentors and monitors of your progress:

### 1. Get common ground with your team
Before doing implementation, you and your team need common ground on what your UI is supposed to do. Get to a place where the whole team feels good about the design. Do this as soon as possible. While you should continue to evolve your design throughout the rest of the semester, you need a clear vision now in order for your implementation efforts to be well-spent.

---

### 2. Outline technical requirements
Figure out what you need your implementation prototypes to do. Recall that implementation prototypes answer questions about how your UI will work, like How will I implement the things that my UI requires? and Will my implementation work well enough?

Each of your technical requirements will look like this:

#. Description of a feature / attribute.
Description of what you concretely need to see when running your prototype to make sure it is satisfied.

Example:
1. Real-time collaboration. In one of my implementation prototypes, I need to show messages passed between two mobile devices with < 0.1 second latency, containing the data I intend to send between devices (messages containing the names of piano keys).

---

### Required “Hello” requirements:
- “Hello world” app  
- “Hello styles.”  

---

### Additional requirement categories:
- Cross-device networking  
- AI (classification, prediction, generation)  
- Drawing libraries  
- Custom input events (gestures, voice, etc.)  
- External APIs/databases  
- Any other technical aspects essential to your UI working correctly  

---

### 3. Meet your project mentor in the first week of A5
You are required to meet your project mentor before Friday, March 27 EOD to check that your requirements list is complete.

- Meetings must be synchronous  
- At least two team members must attend  
- You must get approval  

---

### 4. Code your prototypes

Guidelines:
- Use any languages/frameworks you prefer  
- Ensure your UI runs on the intended device  
- Choose tools your team can realistically learn  

Important:
- Keep implementations minimal  
- Avoid building full features  
- Focus on demonstrating functionality  

---

### Evidence requirement
For each requirement:
- Provide one demonstration of functionality  

---

### Code organization
- One prototype per requirement OR combined  
- Code can be separate or shared  
- Must include clear evidence per requirement  

---

## Tips and Boundaries

### Team coding
Avoid relying on one person; parallelize work.

---

### Design changes
Allowed, but must maintain usefulness and innovativeness.

---

### AI usage
Allowed, but:
- Must be credited  
- Must be understood  
- Must be defensible  

---

### Hardcoding data
Allowed only if indistinguishable from real backend behavior.

---

## Submission Requirements

### Deliverable 1
For each requirement:
- Requirement description  
- Evidence (video, screenshot, console output, etc.)  
- Code link (GitHub permalink)  
- Additional context if needed  

---

### Deliverable 2
- Public GitHub repo  
- README with setup instructions  
- AI attribution  
- Mentor name + meeting date  

---

## General Requirements
- Add all team members  
- Ensure links are clickable  

---

## Grading (35 points)

- 10 pts — Requirements completeness  
- 20 pts — Evidence quality  
- 5 pts — Process clippings  

---

## Appendix: Example Requirements List

1. "Hello world" app  
2. "Hello styles."  
3. Cross-device networking  
4. AI (tune generation)  
5. 2D drawing  
6. External APIs  

---

## Final Note
This assignment focuses on proving that your UI is technically feasible—not building the full production system.
