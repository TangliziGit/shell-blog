# Experience as an LFX Mentee for Chaos Mesh

Hi, I am a graduate student studying software engineering at Nanjing University. My research is in DevOps, which has some connection with software monitoring, and I am also interested in chaos engineering and observability. To get involved in the open-source community, understand Kubernetes more deeply, and experience the infrastructure jobs, I applied for the CNCF LFX Mentorship in Fall 2021 to work on the [Chaos Mesh](https://github.com/chaos-mesh/chaos-mesh) project.



## Application Process

At the end of August, I finished an internship of a business nature. As expected, after being confronted with complex business logic and cluttered code on a daily basis, I decided that I was not well suited for business-related work. However, I always had a strong passion for the technology of infrastructure. Then by chance, I discovered the Chaos Mesh project at CNCF LFX Mentorship, a platform for running chaos experiments on Kubernetes, where mentees will be adding a series of logic and performance related metrics. I thought this was a great opportunity to work on an open source project that I had been dreaming about. I also had the right technology stack, so I tried to submit my resume just before the deadline.



Three days later, I received an interview email from mentor. As part of the interview, the mentor left a small piece of homework, which is in fact a perfect fit for the project: it required us to write a mini-node-exporter that would expose Prometheus metrics and present Grafana dashboard. The addition to the task is to deploy the mini-node-exporter, the configured Prometheus, and Grafana dashboard on the Kubernetes platform. The design and implementation process of it was very smooth, the only difficulty I think is how to write the Grafana dashboard as configuration in the k8s deployment YAML. After a series of documentation queries and experiments, this problem was finally solved successfully.



On August 30, I was lucky enough to receive the good news that I passed the interview. During the one-on-one meeting with the mentor, we simply talked about my familiarity with Kubernetes and other technologies, the main tasks, and some key timelines. I also raised some concerns, such as the pressure of my graduate lab project might affect the progress of the mentorship, the design guidelines for metrics, etc. My mentor addressed my concerns and gave me some information about metrics design after the meeting.



## Project Process

I applied for the project called Monitoring Metrics about Chaos Mesh, which aims to improve the observability of the Chaos Mesh system by collecting metrics and providing a Grafana dashboard.



During the first two weeks of the project, I got familiar with the business process and some code details of chaos mesh. Then in the next two weeks, I started to write the design solution and finally all the metrics design and collection methods were sorted out. During this time, I studied the metrics design guidelines and met with the mentor to understand the details of the proposal and some of the code logic. 



Most of these metrics are relatively simple to collect, requiring only simple queries to database objects, k8s objects, or some simple counts. However, there are some special metrics that are more difficult to collect. For example, you need to query the data by executing commands in the network namespace of the corresponding container, or query all the containers under the daemon through three different container runtimes, or collect data on the communication between the gRPC client and the server.



These tasks were unfamiliar to me. So I had to ask my mentor for technical support and the mentor answered my questions in a very short period of time. This left a very deep impression inside me - my mentor knows a lot. So after doing some communication with the mentor, my initial technical solution was put together, and an [RFC](https://github.com/chaos-mesh/rfcs/pull/23) came up. Later, in order to be able to track my work, I received a suggestion from the mentor to create a [tracking issue](https://github.com/chaos-mesh/chaos-mesh/issues/2397).



![tracking-issue](/static/image/2021-12-03/tracking-issue.png)



However, during the subsequent coding work, I encountered various problems. After trying to solve these problems, I found that many of them could be solved in advance. So I have summarized some suggestions below:



**Keep critical thinking**. When I accepted the proposal up front, I naturally made my solution for each metrics, but ignored some basic questions: Are these metrics necessary? Do we have a better existing solution? These basic questions could not be avoided and should have been addressed during the proposal discussion phase, but they were propagated to the later design implementation phase. For example, when submitting the RFC, I was reminded by mentor and reviewers that some metrics were already implemented by the controller-runtime library. Another example was working on BPM-related metrics, and when I was asked by the reviewer if these metrics were necessary, I realized I had never paid attention to it.



![bpm-issue](/static/image/2021-12-03/bpm-issue.png)



**Continuous communication**. How to communicate effectively is a very important issue in this mentorship. Here are some lessons learned about communication:



\1. think differently. When asking a mentor for help with a technical problem, if you can think of the other person's solution first, then it is best to implement it. Something like "Do I need to open this previously unopened HTTP port?" is simply too obvious from the leader's point of view.



2 . It is better to give options before getting advice. When you have to ask for help, it is best to list some options for the other party to choose from. Although these options may be out of specification, or cost too much. But it contains your own thinking. So don't consume others’ energy outside the scope of their works until you have no ideas.



**Understand open source**. This is my first real involvement in open source work, so I want to compare the differences between working in a company and an open-source community:



\1. The way information is synchronized. Because in the open-source community there are not some ways to synchronize information similar to stand-up meetings, basically all the communication is concentrated in slack, issues, and PR. So we need to record our work so that we can always let the mentor know what is going on. In the first few weeks, I maintained an online R&D document based on my previous habit. Later I found that it was better to set up a Kanban or issue on GitHub, so as to avoid introducing other platforms to consume the mentor's energy.



![RD-document](/static/image/2021-12-03/RD-document.png)



\2. better and more rigorous automated testing. Before PR submission, we need to do local unit tests and self-test. after PR submission will trigger GitHub Actions and some bots for more static analysis and testing process. Many unsafe and non-standard codes will be checked here.



\3. code review. Many people will participate in your code reviews, and the review will last for a long time. Unlike company work, there are no dedicated testers in open source work. Often a large number of users and maintainers fill this part of the job, which may be part of the reason for the long review phase.



## After the project

I had a wonderful experience in these short 12 weeks. I gained a deeper understanding of Kubernetes, CRD, and observability, but also realized that I was still lacking a lot of knowledge on how to improve code structure, Linux basics, and the knowledge of container technology. There is still more knowledge to learn!



At the same time, because of the unexpected pressure of the graduate lab project, I have less energy for mentorship, and even the Grafana part has not yet been given a design. I will follow up on it and hope to finish it successfully and give a real conclusion to this project.



Then, I would like to thank my mentor [@STRRL](https://github.com/STRRL). During my internship, I encountered big and small problems in the project, such as Git operations, cycle dependency solutions, finding the runtime interface for CRI-O, etc. Without my mentor's patience and guidance, it would have been difficult for me to complete these unfamiliar technical challenges. I would also like to thank the maintainers of Chaos Mesh for reviewing my code, and the CNCF LFX Mentorship project for providing a great platform for all of us who want to participate in the open-source community.



![mentor's-LGTM](/static/image/2021-12-03/mentor's-LGTM.png)



Finally, I hope every student who wants to be part of the open-source community can take the first step with LFX Mentorship!