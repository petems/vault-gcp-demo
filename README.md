# vault-gcp-demo

A repository to demo Vault in GCP, using the GCP authentication backend.

<img width="646" alt="GCP IAM Workflow" src="https://user-images.githubusercontent.com/1064715/43199644-9010d5d2-900a-11e8-8504-9850589cd480.png">

For more information, read the following:

## Running the Demo

You have a choice...

### Locally with NGROK

If you want to more expliclty see how things work, manually create instance in the GCP web-gui, and run Vault on your local machine to get things up and running ASAP, follow the [Locally with NGROK](Locally_with_NGROK.md) instructions.

### Remotely in GCP with Terraform

If you want to do things more auto-magically, you can create all the resources with Terraform and have all the required setup and scripts created on the machines themselves. You should use [In GCP with Terraform.md](In_GCP_with_Terraform.md) This is also more useful as you can give it to someone who already has a GCP environment and just wants to see how things work in their own environment.
