Just some powershell to get an AD lab setup.

bAD.md = Initial Setup of Active Directory. The powershell commands will need to be run on the domain controller and the workstation computer so it's not automated but it shouldn't take too long.

bAD-kerberoast.ps1 = Run on domain controller, will set up a service account named kirby that can be kerberoasted.

![Kirby the kerberoast](kerberoast.png)

bAD-UKD.ps1 = Run on domain controller, will give trusted for delegation rights to the other machine. 

![Cannot be constrained](ukd.png)

## Testing Guide
# Kerberoasting (payload on non domain controller run as wadmin)

![Kirby Roasted](kerberoast-testing.png)

# Unconstrained Delegation

*Please note information such as luids, tickets, etc... may change, it took me a few minutes to get it working in sliver*

Using sharpview to search for unconstrained delegation

![command](sharpview_search.png)

![results](workstation_trusted_for_delegation.png)

Nothing to exploit

![unconstrained nothing to triage](unconstrained_triage_start.png)

Cannot view c$ on Domain Controller

![maidenless](no_priv.png)

Authenticate to machine somehow, I just ls'd into the machine as Thackerman

![show me files](lsthackerman.png)

Dump the resulting luid with rubeus

![dump luid](dump_luid.png)

Pass the Ticket to current luid with rubeus

![command](pass_the_ticket_command.png)

![results](pass_the_ticket_results.png)

Profit

![profit](profit.png)