[CmdletBinding()]
param(
)
$M365DSCTestFolder = Join-Path -Path $PSScriptRoot `
                        -ChildPath "..\..\Unit" `
                        -Resolve
$CmdletModule = (Join-Path -Path $M365DSCTestFolder `
            -ChildPath "\Stubs\Microsoft365.psm1" `
            -Resolve)
$GenericStubPath = (Join-Path -Path $M365DSCTestFolder `
    -ChildPath "\Stubs\Generic.psm1" `
    -Resolve)
Import-Module -Name (Join-Path -Path $M365DSCTestFolder `
        -ChildPath "\UnitTestHelper.psm1" `
        -Resolve)

$Global:DscHelper = New-M365DscUnitTestHelper -StubModule $CmdletModule `
    -DscResource "EXOOnPremisesOrganization" -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope

        BeforeAll {
            $secpasswd = ConvertTo-SecureString "test@password1" -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ("tenantadmin", $secpasswd)

            Mock -CommandName Update-M365DSCExportAuthenticationResults -MockWith {
                return @{}
            }

            Mock -CommandName Get-M365DSCExportContentForResource -MockWith {

            }

            Mock -CommandName New-M365DSCConnection -MockWith {
                return "Credential"
            }

            Mock -CommandName Get-PSSession -MockWith {

            }

            Mock -CommandName Remove-PSSession -MockWith {

            }
        }

        # Test contexts
        Context -Name "On-Premises Organization should exist. On-Premises Organization is missing. Test should fail." -Fixture {
            BeforeAll {
                $testParams = @{
                    Identity                 = "ContosoMail"
                    Comment                  = "Hello World"
                    HybridDomains            = "contoso.com"
                    InboundConnector         = "Inbound to ExchangeMail"
                    OrganizationName         = "Contoso"
                    OrganizationGuid         = "a1bc23cb-3456-bcde-abcd-feb363cacc88"
                    OrganizationRelationship = ""
                    OutboundConnector        = "Outbound to ExchangeMail"
                    Ensure                   = 'Present'
                    Credential       = $Credential
                }

                Mock -CommandName Get-OnPremisesOrganization -MockWith {
                    return @{
                        Identity                 = "ContosoMailDifferent"
                        Comment                  = "Hello World"
                        HybridDomains            = "contoso.com"
                        InboundConnector         = "Inbound to ExchangeMail"
                        OrganizationName         = "Contoso"
                        OrganizationGuid         = "a1bc23cb-3456-bcde-abcd-feb363cacc88"
                        OrganizationRelationship = ""
                        OutboundConnector        = "Outbound to ExchangeMail"
                        FreeBusyAccessLevel      = 'AvailabilityOnly'
                    }
                }

                Mock -CommandName Set-OnPremisesOrganization -MockWith {
                    return @{
                        Identity                 = "ContosoMail"
                        Comment                  = "Hello World"
                        HybridDomains            = "contoso.com"
                        InboundConnector         = "Inbound to ExchangeMail"
                        OrganizationName         = "Contoso"
                        OrganizationGuid         = "a1bc23cb-3456-bcde-abcd-feb363cacc88"
                        OrganizationRelationship = ""
                        OutboundConnector        = "Outbound to ExchangeMail"
                        Credential       = $Credential
                    }
                }

            }

            It 'Should return false from the Test method' {
                Test-TargetResource @testParams | Should -Be $false
            }

            It "Should call the Set method" {
                Set-TargetResource @testParams
            }

            It "Should return Absent from the Get method" {
                (Get-TargetResource @testParams).Ensure | Should -Be "Absent"
            }
        }

        Context -Name "On-Premises Organization should exist. On-Premises Organization exists. Test should pass." -Fixture {
            BeforeAll {
                $testParams = @{
                    Identity                 = "ContosoMail"
                    Comment                  = "Hello World"
                    HybridDomains            = "contoso.com"
                    InboundConnector         = "Inbound to ExchangeMail"
                    OrganizationName         = "Contoso"
                    OrganizationGuid         = "a1bc23cb-3456-bcde-abcd-feb363cacc88"
                    OrganizationRelationship = ""
                    OutboundConnector        = "Outbound to ExchangeMail"
                    Ensure                   = 'Present'
                    Credential       = $Credential
                }

                Mock -CommandName Get-OnPremisesOrganization -MockWith {
                    return @{
                        Identity                 = "ContosoMail"
                        Comment                  = "Hello World"
                        HybridDomains            = "contoso.com"
                        InboundConnector         = "Inbound to ExchangeMail"
                        OrganizationName         = "Contoso"
                        OrganizationGuid         = "a1bc23cb-3456-bcde-abcd-feb363cacc88"
                        OrganizationRelationship = ""
                        OutboundConnector        = "Outbound to ExchangeMail"
                    }
                }
            }

            It 'Should return true from the Test method' {
                Test-TargetResource @testParams | Should -Be $true
            }

            It 'Should return Present from the Get Method' {
                (Get-TargetResource @testParams).Ensure | Should -Be "Present"
            }
        }

        Context -Name "On-Premises Organization should exist. On-Premises Organization exists, InboundConnector mismatch. Test should fail." -Fixture {
            BeforeAll {
                $testParams = @{
                    Identity                 = "ContosoMail"
                    Comment                  = "Hello World"
                    HybridDomains            = "contoso.com"
                    InboundConnector         = "Inbound to ExchangeMail"
                    OrganizationName         = "Contoso"
                    OrganizationGuid         = "a1bc23cb-3456-bcde-abcd-feb363cacc88"
                    OrganizationRelationship = ""
                    OutboundConnector        = "Outbound to ExchangeMail"
                    Ensure                   = 'Present'
                    Credential       = $Credential
                }

                Mock -CommandName Get-OnPremisesOrganization -MockWith {
                    return @{
                        Identity                 = "ContosoMail"
                        Comment                  = "Hello World"
                        HybridDomains            = "contoso.com"
                        InboundConnector         = "Different Inbound to ExchangeMail"
                        OrganizationName         = "Contoso"
                        OrganizationGuid         = "a1bc23cb-3456-bcde-abcd-feb363cacc88"
                        OrganizationRelationship = ""
                        OutboundConnector        = "Outbound to ExchangeMail"
                    }
                }

                Mock -CommandName Set-OnPremisesOrganization -MockWith {
                    return @{
                        Identity                 = "ContosoMail"
                        Comment                  = "Hello World"
                        HybridDomains            = "contoso.com"
                        InboundConnector         = "Inbound to ExchangeMail"
                        OrganizationName         = "Contoso"
                        OrganizationGuid         = "a1bc23cb-3456-bcde-abcd-feb363cacc88"
                        OrganizationRelationship = ""
                        OutboundConnector        = "Outbound to ExchangeMail"
                    }
                }
            }

            It 'Should return false from the Test method' {
                Test-TargetResource @testParams | Should -Be $false
            }

            It "Should call the Set method" {
                Set-TargetResource @testParams
            }
        }

        Context -Name "ReverseDSC Tests" -Fixture {
            BeforeAll {
                $testParams = @{
                    Credential = $Credential
                }

                $OnPremisesOrganization = @{
                    Identity                 = "ContosoMail"
                    Comment                  = "Hello World"
                    HybridDomains            = "contoso.com"
                    InboundConnector         = "Inbound to ExchangeMail"
                    OrganizationName         = "Contoso"
                    OrganizationGuid         = "a1bc23cb-3456-bcde-abcd-feb363cacc88"
                    OrganizationRelationship = ""
                    OutboundConnector        = "Outbound to ExchangeMail"
                }

                Mock -CommandName Get-OnPremisesOrganization -MockWith {
                    return $OnPremisesOrganization
                }
            }

            It "Should Reverse Engineer resource from the Export method when single" {
                Export-TargetResource @testParams
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
