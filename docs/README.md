# Docs

Miscellaneous is gathered here.

## Thoughts on Automation

In short, my philosophy regarding automation is:
> **ALWAYS** do the thing manually* first to gather contextual information.
>
> Incrementatlly automate components of your workflow if it makes sense, but keep it targetted.
>
> \*_using CLI tools to enhance your manual efforts is fine, just make sure you know what the tool is doing!_

I'm quite fond of shell scripts because they're the quickest way to talk to your computer, high leverage, and a good heuristic of complexity:
you can do a lot in a few lines of bash, but if your script is starting to get overly complicated, then you're
trying to do too much at once.

Keep things as stupidly simple as possible.
Play around with different tools and configuration options, and make note of what you like.

### Configuring and Deploying
Software needs to be configured in order to function in a way that is useful,
however that software might depend on other software which also needs to be configured in some way.
Exactly how this is done is rather context specific, as it largely depends on
WHAT is being deployed onto, and WHY.

For example, if I want to setup a personal computer, I will want a straightforward user-interface,
and various applications that enable me to perform a range of computing tasks,
such coding CLI tools nobody uses in an IDE I've spent far too much time "customising".

Setting-up a computer that knows how I want things cusomised,
can largely be automated using a combination of configuration files and scripting,
in what is often referred to as "Configuration as Code" (CasC).

### But what about Provisioning?
Physical computers will always need to be provisioned manually at least once.
If configured to host VMs using a virtualisation platform,
then they can be provisioned automatically with
"Infrastructure as Code" (IaC) tools like Terraform.

Although an individual may want to use Terraform to automate provisioning their IT infrastructure
for their home-lab or small business, in my opinion IaC tools are not applicable to every situation.
For example, if I just want to be able to backup, format, reinstall, and configure
my personal computer, in such a way that won't take me a whole week every time,
then IaC is not relevant because there's no additional IT infrastructre besides my laptop that needs to be provisioned.
I'll spend a week setting up the CasC so I can setup my personal computer in an hour.

If I have no idea how I want my computer to be setup, then I'll not bother with CasC and just cobble something together.
After a period of experimentation may find some arrangement that I want to capture as CasC.
