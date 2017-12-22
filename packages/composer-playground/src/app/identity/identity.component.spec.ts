/* tslint:disable:no-unused-variable */
/* tslint:disable:no-unused-expression */
/* tslint:disable:no-var-requires */
/* tslint:disable:max-classes-per-file */
import { Component, Input, Output, Directive } from '@angular/core';
import { ComponentFixture, TestBed, fakeAsync, tick } from '@angular/core/testing';
import { FormsModule } from '@angular/forms';
import { Resource } from 'composer-common';

import { NgbModal } from '@ng-bootstrap/ng-bootstrap';

import { IdentityComponent } from './identity.component';
import { IssueIdentityComponent } from './issue-identity';
import { AlertService } from '../basic-modals/alert.service';
import { ClientService } from '../services/client.service';
import { IdentityCardService } from '../services/identity-card.service';
import { BusinessNetworkConnection, ParticipantRegisty } from 'composer-client';
import { IdCard } from 'composer-common';

import * as fileSaver from 'file-saver';

import * as chai from 'chai';

import * as sinon from 'sinon';

let should = chai.should();

@Component({
    selector: 'app-footer',
    template: ''
})
class MockFooterComponent {

}

@Directive({
    selector: '[ngbTooltip]'
})
class MockToolTipDirective {
    @Input() public ngbTooltip: string;
    @Input() public placement: string;
    @Input() public container: string;
}

describe(`IdentityComponent`, () => {

    let component: IdentityComponent;
    let fixture: ComponentFixture<IdentityComponent>;

    let mockModal;
    let mockAlertService;
    let mockIdentityCardService;
    let mockClientService;
    let mockBusinessNetworkConnection;
    let mockCard;
    let mockIDCards: Map<string, IdCard>;

    beforeEach(() => {

        mockCard = sinon.createStubInstance(IdCard);
        mockCard.getBusinessNetworkName.returns('myNetwork');
        mockCard.getConnectionProfile.returns({name: 'myProfile'});
        mockCard.getUserName.returns('myName');

        mockIDCards = new Map<string, IdCard>();
        mockIDCards.set('1234', mockCard);
        mockIDCards.set('4321', mockCard);

        mockModal = sinon.createStubInstance(NgbModal);
        mockAlertService = sinon.createStubInstance(AlertService);
        mockIdentityCardService = sinon.createStubInstance(IdentityCardService);
        mockClientService = sinon.createStubInstance(ClientService);
        mockBusinessNetworkConnection = sinon.createStubInstance(BusinessNetworkConnection);

        mockAlertService.errorStatus$ = {next: sinon.stub()};
        mockAlertService.successStatus$ = {next: sinon.stub()};
        mockAlertService.busyStatus$ = {next: sinon.stub()};

        mockClientService.ensureConnected.returns(Promise.resolve(true));
        mockBusinessNetworkConnection.getIdentityRegistry.returns(Promise.resolve({
            getAll: sinon.stub().returns([{name: 'adminPenguin', state: 'READY', participant: {
                getType: () => { return 'NetworkAdmin'; },
                getNamespace: () => { return 'org.acme.animals'; },
                getIdentifier: () => { return 'Pingu'; },
              }}, {name: 'revokedPenguin', state: 'REVOKED', participant: {
                getType: () => { return 'Penguin'; },
                getNamespace: () => { return 'org.acme.animals'; },
                getIdentifier: () => { return 'Pinga'; },
              }}, {name: 'missingPenguin', state: 'READY', participant: {
                getType: () => { return 'Penguin'; },
                getNamespace: () => { return 'org.acme.animals'; },
                getIdentifier: () => { return 'Pingo'; },
              }}, {name: 'happyPenguin', state: 'READY', participant: {
                getType: () => { return 'Penguin'; },
                getNamespace: () => { return 'org.acme.animals'; },
                getIdentifier: () => { return 'Pingi'; },
              }}])
        }));
        mockClientService.getBusinessNetworkConnection.returns(mockBusinessNetworkConnection);

        mockClientService.getBusinessNetwork.returns({
            getName: sinon.stub().returns('name')
        });

        TestBed.configureTestingModule({
            imports: [FormsModule],
            declarations: [
                IdentityComponent,
                MockFooterComponent,
                MockToolTipDirective
            ],
            providers: [
                {provide: NgbModal, useValue: mockModal},
                {provide: AlertService, useValue: mockAlertService},
                {provide: ClientService, useValue: mockClientService},
                {provide: IdentityCardService, useValue: mockIdentityCardService},
            ]
        });

        fixture = TestBed.createComponent(IdentityComponent);

        component = fixture.componentInstance;
    });

    describe('ngOnInit', () => {
        it('should create the component', () => {
            component.should.be.ok;
        });

        it('should load the component', fakeAsync(() => {
            let loadMock = sinon.stub(component, 'loadAllIdentities').returns(Promise.resolve());

            component.ngOnInit();

            tick();

            loadMock.should.have.been.called;
        }));
    });

    describe('loadAllIdentities', () => {
        it('should load the identities and handle those bound to participants not found', fakeAsync(() => {
            mockClientService.getBusinessNetwork.returns({getName: sinon.stub().returns('myNetwork')});
            let myLoadParticipantsMock = sinon.stub(component, 'loadParticipants');
            let myGetParticipantMock = sinon.stub(component, 'getParticipant');
            let myIdentityMock = sinon.stub(component, 'loadMyIdentities');
            myLoadParticipantsMock.returns(Promise.resolve());
            myGetParticipantMock.onFirstCall().returns(true);
            myGetParticipantMock.onSecondCall().returns(false);

            mockIdentityCardService.getCurrentIdentityCard.returns({
                getConnectionProfile: sinon.stub().returns({name: 'myProfile'})
            });

            mockIdentityCardService.getQualifiedProfileName.returns('qpn');
            mockIdentityCardService.getCardRefFromIdentity.onFirstCall().returns('1234');
            mockIdentityCardService.getCardRefFromIdentity.onSecondCall().returns('4321');
            mockIdentityCardService.getCardRefFromIdentity.onThirdCall().returns('2341');
            mockIdentityCardService.getCardRefFromIdentity.onCall(3).returns('3412');

            component.loadAllIdentities();

            tick();

            component['businessNetworkName'].should.equal('myNetwork');
            myLoadParticipantsMock.should.have.been.called;
            myGetParticipantMock.should.have.been.called;
            myIdentityMock.should.have.been.called;

            mockIdentityCardService.getCurrentIdentityCard.should.have.been.called;
            mockIdentityCardService.getQualifiedProfileName.should.have.been.calledWith({name: 'myProfile'});
            mockIdentityCardService.getCardRefFromIdentity.should.have.callCount(4);
            mockIdentityCardService.getCardRefFromIdentity.firstCall.should.have.been.calledWith('adminPenguin', 'myNetwork', 'qpn');
            mockIdentityCardService.getCardRefFromIdentity.secondCall.should.have.been.calledWith('happyPenguin', 'myNetwork', 'qpn');
            mockIdentityCardService.getCardRefFromIdentity.thirdCall.should.have.been.calledWith('missingPenguin', 'myNetwork', 'qpn');
            mockIdentityCardService.getCardRefFromIdentity.lastCall.should.have.been.calledWith('revokedPenguin', 'myNetwork', 'qpn');

            component['allIdentities'].should.have.lengthOf(4);
            component['allIdentities'][0].should.have.property('name', 'adminPenguin');
            component['allIdentities'][0].should.have.property('ref', '1234');
            component['allIdentities'][0].should.have.property('state', 'READY');
            component['allIdentities'][1].should.have.property('name', 'happyPenguin');
            component['allIdentities'][1].should.have.property('ref', '4321');
            component['allIdentities'][1].should.have.property('state', 'READY');
            component['allIdentities'][2].should.have.property('name', 'missingPenguin');
            component['allIdentities'][2].should.have.property('ref', '2341');
            component['allIdentities'][2].should.have.property('state', 'IDENTIFIER NOT FOUND');
            component['allIdentities'][3].should.have.property('name', 'revokedPenguin');
            component['allIdentities'][3].should.have.property('ref', '3412');
            component['allIdentities'][3].should.have.property('state', 'REVOKED');

        }));

        it('should give an alert if there is an error', fakeAsync(() => {

            let myLoadParticipantsMock = sinon.stub(component, 'loadParticipants');
            myLoadParticipantsMock.returns(Promise.resolve());

            mockBusinessNetworkConnection.getIdentityRegistry.returns(Promise.reject('some error'));

            component.loadAllIdentities();

            tick();
            myLoadParticipantsMock.should.have.been.called;
            mockBusinessNetworkConnection.getIdentityRegistry.should.have.been.called;

            mockAlertService.errorStatus$.next.should.have.been.calledWith('some error');
        }));
    });

    describe('loadMyIdentities', () => {
        it('should load identities for a business network setting usable depening on state', () => {
            mockIdentityCardService.currentCard = '1234';

            component['allIdentities'] = [{ref: '1234', state: 'READY'}, {ref: '4321', state: 'IDENTIFIER NOT FOUND'}];

            mockIdentityCardService.getCurrentIdentityCard.returns(mockCard);
            mockIdentityCardService.getQualifiedProfileName.returns('web-profile');

            mockIdentityCardService.getAllCardsForBusinessNetwork.returns(mockIDCards);

            component.loadMyIdentities();

            component['currentIdentity'].should.equal('1234');
            mockIdentityCardService.getCurrentIdentityCard.should.have.been.calledTwice;

            mockCard.getBusinessNetworkName.should.have.been.called;
            mockCard.getConnectionProfile.should.have.been.called;

            mockIdentityCardService.getQualifiedProfileName.should.have.been.calledWith({name: 'myProfile'});

            mockIdentityCardService.getAllCardsForBusinessNetwork.should.have.been.calledWith('myNetwork', 'web-profile');
            component['identityCards'].should.deep.equal(mockIDCards);

            component['myIDs'].should.deep.equal([{ref: '1234', usable: true }, {ref: '4321', usable: false }]);
        });
    });

    describe('issueNewId', () => {
        let mockGetConnectionProfile;
        let mockLoadAllIdentities;
        let mockAddIdentityToWallet;
        let mockShowNewId;

        beforeEach(() => {
            mockModal.open.reset();

            mockGetConnectionProfile = sinon.stub();

            mockIdentityCardService.getCurrentIdentityCard.returns({
                getConnectionProfile: mockGetConnectionProfile
            });

            mockLoadAllIdentities = sinon.stub(component, 'loadAllIdentities');
            mockAddIdentityToWallet = sinon.stub(component, 'addIdentityToWallet');
            mockShowNewId = sinon.stub(component, 'showNewId');
        });

        it('should show the new id', fakeAsync(() => {
            let p1 = new Resource('resource1');
            let p2 = new Resource('resource2');
            component['participants'].set('bob', p1);
            component['participants'].set('sally', p2);

            mockGetConnectionProfile.returns({
                'x-type': 'hlfv1'
            });

            mockModal.open.returns({
                componentInstance: {},
                result: Promise.resolve({userID: 'myId', userSecret: 'mySecret'})
            });

            component.issueNewId();

            tick();

            mockAddIdentityToWallet.should.not.have.been.called;
            mockShowNewId.should.have.been.called;
            mockLoadAllIdentities.should.have.been.called;
        }));

        it('should add id to wallet when using the web profile', fakeAsync(() => {
            mockGetConnectionProfile.returns({
                'x-type': 'web'
            });

            mockModal.open.returns({
                componentInstance: {},
                result: Promise.resolve({userID: 'myId', userSecret: 'mySecret'})
            });

            component.issueNewId();

            tick();

            mockAddIdentityToWallet.should.have.been.called;
            mockShowNewId.should.not.have.been.called;
            mockLoadAllIdentities.should.have.been.called;
        }));

        it('should handle error in id creation', fakeAsync(() => {
            mockModal.open.returns({
                componentInstance: {},
                result: Promise.reject('some error')
            });

            mockAlertService.errorStatus$.next.should.not.have.been.called;

            component.issueNewId();

            tick();

            mockModal.open.should.have.been.calledOnce;

            mockAlertService.errorStatus$.next.should.have.been.calledWith('some error');

            mockLoadAllIdentities.should.have.been.called;
        }));

        it('should handle error showing new identity', fakeAsync(() => {
            mockGetConnectionProfile.returns({
                'x-type': 'hlfv1'
            });

            mockModal.open.returns({
                componentInstance: {},
                result: Promise.resolve({userID: 'myId', userSecret: 'mySecret'})
            });

            mockShowNewId.rejects(new Error('show new id error'));

            mockAlertService.errorStatus$.next.should.not.have.been.called;

            component.issueNewId();

            tick();

            mockModal.open.should.have.been.calledOnce;

            let expectedError = sinon.match(sinon.match.instanceOf(Error).and(sinon.match.has('message', 'show new id error')));
            mockAlertService.errorStatus$.next.should.have.been.calledWith(expectedError);

            mockLoadAllIdentities.should.have.been.called;
        }));

        it('should handle error adding identity to wallet', fakeAsync(() => {
            mockGetConnectionProfile.returns({
                'x-type': 'web'
            });

            mockModal.open.returns({
                componentInstance: {},
                result: Promise.resolve({userID: 'myId', userSecret: 'mySecret'})
            });

            mockAddIdentityToWallet.rejects(new Error('add identity to wallet error'));

            mockAlertService.errorStatus$.next.should.not.have.been.called;

            component.issueNewId();

            tick();

            mockModal.open.should.have.been.calledOnce;

            let expectedError = sinon.match(sinon.match.instanceOf(Error).and(sinon.match.has('message', 'add identity to wallet error')));
            mockAlertService.errorStatus$.next.should.have.been.calledWith(expectedError);

            mockLoadAllIdentities.should.have.been.called;
        }));

        it('should handle error reloading identities', fakeAsync(() => {
            mockModal.open.returns({
                componentInstance: {},
                result: Promise.resolve({userID: 'myId', userSecret: 'mySecret'})
            });

            mockLoadAllIdentities.returns(Promise.reject('some error'));

            mockAlertService.errorStatus$.next.should.not.have.been.called;

            component.issueNewId();

            tick();

            mockModal.open.should.have.been.calledOnce;

            mockAlertService.errorStatus$.next.should.have.been.calledWith('some error');

            mockLoadAllIdentities.should.have.been.called;
        }));

        it('should handle escape being pressed', fakeAsync(() => {
            mockModal.open.returns({
                componentInstance: {},
                result: Promise.reject(1)
            });

            mockAlertService.errorStatus$.next.should.not.have.been.called;

            component.issueNewId();

            tick();

            mockModal.open.should.have.been.calledOnce;

            mockAlertService.errorStatus$.next.should.not.have.been.called;

            mockLoadAllIdentities.should.have.been.called;
        }));

        it('should not issue identity if cancelled', fakeAsync(() => {
            mockModal.open.returns({
                componentInstance: {},
                result: Promise.resolve()
            });

            mockAlertService.errorStatus$.next.should.not.have.been.called;

            component.issueNewId();

            tick();

            mockAlertService.errorStatus$.next.should.not.have.been.called;
            mockLoadAllIdentities.should.have.been.called;

        }));
    });

    describe('showNewId', () => {
        let mockExportIdentity;

        beforeEach(() => {
            mockModal.open.reset();
            mockExportIdentity = sinon.stub(component, 'exportIdentity');
        });

        it('should add card to wallet when add option selected', fakeAsync(() => {
            mockModal.open.returns({
                componentInstance: {},
                result: Promise.resolve({cardRef: '1234', choice: 'add'})
            });

            mockIdentityCardService.getIdentityCard.returns(mockCard);

            component.showNewId({userID: 'myId', userSecret: 'mySecret'});

            tick();

            mockModal.open.should.have.been.called;
            mockIdentityCardService.getIdentityCard.should.have.been.calledWith('1234');
            mockAlertService.successStatus$.next.should.have.been.calledWith({
                title: 'ID Card added to wallet',
                text: 'The ID card myName was successfully added to your wallet',
                icon: '#icon-role_24'
            });

            mockExportIdentity.should.not.have.been.called;
        }));

        it('should export card when export option selected', fakeAsync(() => {
            mockModal.open.returns({
                componentInstance: {},
                result: Promise.resolve({card: 'myCard', choice: 'export'})
            });

            component.showNewId({userID: 'myId', userSecret: 'mySecret'});

            tick();

            mockModal.open.should.have.been.called;
            mockAlertService.successStatus$.next.should.not.have.been.called;
            mockExportIdentity.should.have.been.calledWith('myCard');
        }));

        it('should do nothing for other options', fakeAsync(() => {
            mockModal.open.returns({
                componentInstance: {},
                result: Promise.resolve({card: 'myCard', choice: 'other'})
            });

            component.showNewId({userID: 'myId', userSecret: 'mySecret'});

            tick();

            mockModal.open.should.have.been.called;
            mockAlertService.successStatus$.next.should.not.have.been.called;
            mockExportIdentity.should.not.have.been.called;
        }));

        it('should do nothing when closed', fakeAsync(() => {
            mockModal.open.returns({
                componentInstance: {},
                result: Promise.resolve()
            });

            component.showNewId({userID: 'myId', userSecret: 'mySecret'});

            tick();

            mockModal.open.should.have.been.called;
            mockAlertService.successStatus$.next.should.not.have.been.called;
            mockExportIdentity.should.not.have.been.called;
        }));
    });

    describe('addIdentityToWallet', () => {
        it('should add identity to wallet', fakeAsync(() => {
            mockIdentityCardService.getCurrentIdentityCard.returns(mockCard);
            mockIdentityCardService.createIdentityCard.resolves('cardref');
            mockIdentityCardService.getIdentityCard.returns(mockCard);

            component.addIdentityToWallet({userID: 'myName', userSecret: 'mySecret'});

            tick();

            mockIdentityCardService.createIdentityCard.should.have.been.calledWith('myName', null, 'myNetwork', 'mySecret', {name: 'myProfile'});
            mockIdentityCardService.getIdentityCard.should.have.been.calledWith('cardref');
            mockAlertService.successStatus$.next.should.have.been.calledWith({
                title: 'ID Card added to wallet',
                text: 'The ID card myName was successfully added to your wallet',
                icon: '#icon-role_24'
            });
        }));
    });

    describe('exportIdentity', () => {
        let sandbox = sinon.sandbox.create();
        let saveAsStub;

        beforeEach(() => {
            saveAsStub = sandbox.stub(fileSaver, 'saveAs');
        });

        afterEach(() => {
            sandbox.restore();
        });

        it('should export idcard', fakeAsync(() => {
            mockCard.toArchive.returns(Promise.resolve('card data'));

            component.exportIdentity(mockCard);

            tick();

            let expectedFile = new Blob(['card data'], {type: 'application/octet-stream'});
            saveAsStub.should.have.been.calledWith(expectedFile, 'myName.card');
        }));
    });

    describe('setCurrentIdentity', () => {
        it('should set the current identity', fakeAsync(() => {
            let loadAllIdentities = sinon.stub(component, 'loadAllIdentities');
            mockIdentityCardService.setCurrentIdentityCard.returns(Promise.resolve());
            mockClientService.ensureConnected.returns(Promise.resolve());

            component.setCurrentIdentity({ref: '1234', usable: true});

            tick();

            component['currentIdentity'].should.equal('1234');
            mockIdentityCardService.setCurrentIdentityCard.should.have.been.calledWith('1234');
            mockClientService.ensureConnected.should.have.been.calledWith(true);
            mockAlertService.busyStatus$.next.should.have.been.calledTwice;
            loadAllIdentities.should.have.been.called;
        }));

        it('should do nothing if the new identity matches the current identity', fakeAsync(() => {
            let loadAllIdentities = sinon.stub(component, 'loadAllIdentities');
            component['currentIdentity'] = '1234';

            component.setCurrentIdentity({ref: '1234', usable: true});

            tick();

            component['currentIdentity'].should.equal('1234');
            loadAllIdentities.should.not.have.been.called;
            mockIdentityCardService.setCurrentIdentityCard.should.not.have.been.called;
            mockClientService.ensureConnected.should.not.have.been.called;
            mockAlertService.busyStatus$.next.should.not.have.been.called;
        }));

        it('should handle errors', fakeAsync(() => {
            mockClientService.ensureConnected.returns(Promise.reject('Testing'));
            mockIdentityCardService.setCurrentIdentityCard.returns(Promise.resolve());
            component.setCurrentIdentity({ref: '1234', usable: true});

            tick();

            mockAlertService.busyStatus$.next.should.have.been.calledTwice;
            mockAlertService.busyStatus$.next.should.have.been.calledWith(null);
            mockAlertService.errorStatus$.next.should.have.been.called;
        }));
    });

    describe('openRemoveModal', () => {
        it('should open the delete-confirm modal', fakeAsync(() => {
            component['identityCards'] = mockIDCards;
            let loadMock = sinon.stub(component, 'loadAllIdentities');

            mockModal.open = sinon.stub().returns({
                componentInstance: {},
                result: Promise.resolve()
            });

            component.openRemoveModal('1234');
            tick();

            mockModal.open.should.have.been.called;
        }));

        it('should open the delete-confirm modal and handle error', fakeAsync(() => {
            component['identityCards'] = mockIDCards;
            mockModal.open = sinon.stub().returns({
                componentInstance: {},
                result: Promise.reject('some error')
            });

            component.openRemoveModal('1234');
            tick();

            mockAlertService.busyStatus$.next.should.have.been.called;
            mockAlertService.errorStatus$.next.should.have.been.called;
        }));

        it('should open the delete-confirm modal and handle cancel', fakeAsync(() => {
            component['identityCards'] = mockIDCards;
            mockModal.open = sinon.stub().returns({
                componentInstance: {},
                result: Promise.reject(null)
            });

            component.openRemoveModal('1234');
            tick();

            mockAlertService.busyStatus$.next.should.not.have.been.called;
            mockAlertService.errorStatus$.next.should.not.have.been.called;
        }));

        it('should open the delete-confirm modal and handle remove press', fakeAsync(() => {
            component['identityCards'] = mockIDCards;
            let mockRemoveIdentity = sinon.stub(component, 'removeIdentity').returns(Promise.resolve());

            mockModal.open = sinon.stub().returns({
                componentInstance: {},
                result: Promise.resolve(true)
            });

            component.openRemoveModal('1234');

            tick();

            mockAlertService.busyStatus$.next.should.have.been.called;
            mockRemoveIdentity.should.have.been.calledWith('1234');
        }));
    });
    describe('removeIdentity', () => {
      it('should remove the identity from the wallet', fakeAsync(() => {
          component['identityCards'] = mockIDCards;
          mockIdentityCardService.deleteIdentityCard.returns(Promise.resolve());

          mockModal.open = sinon.stub().returns({
              componentInstance: {},
              result: Promise.resolve(true)
          });

          let mockLoadAllIdentities = sinon.stub(component, 'loadAllIdentities');

          component.removeIdentity('1234');

          tick();

          mockAlertService.busyStatus$.next.should.have.been.called;
          mockIdentityCardService.deleteIdentityCard.should.have.been.calledWith('1234');
          mockLoadAllIdentities.should.have.been.called;

          mockAlertService.busyStatus$.next.should.have.been.called;
          mockAlertService.successStatus$.next.should.have.been.called;
          mockAlertService.errorStatus$.next.should.not.have.been.called;
      }));
      it('should handle error when removing from wallet', fakeAsync(() => {
            component['identityCards'] = mockIDCards;
            mockIdentityCardService.deleteIdentityCard.returns(Promise.reject('some error'));

            mockModal.open = sinon.stub().returns({
                componentInstance: {},
                result: Promise.resolve(true)
            });

            let mockLoadAllIdentities = sinon.stub(component, 'loadAllIdentities');

            component.removeIdentity('1234');

            tick();

            mockIdentityCardService.deleteIdentityCard.should.have.been.calledWith('1234');
            mockLoadAllIdentities.should.not.have.been.called;

            mockAlertService.busyStatus$.next.should.have.been.called;
            mockAlertService.errorStatus$.next.should.have.been.calledWith('some error');
        }));
    });

    describe('revokeIdentity', () => {
        it('should open the delete-confirm modal', fakeAsync(() => {

            mockModal.open = sinon.stub().returns({
                componentInstance: {},
                result: Promise.resolve()
            });

            component.revokeIdentity({name: 'fred'});
            tick();

            mockModal.open.should.have.been.called;
        }));

        it('should open the delete-confirm modal and handle error', fakeAsync(() => {

            mockModal.open = sinon.stub().returns({
                componentInstance: {},
                result: Promise.reject('some error')
            });

            component.revokeIdentity({name: 'fred'});
            tick();

            mockAlertService.busyStatus$.next.should.have.been.called;
            mockAlertService.errorStatus$.next.should.have.been.called;
        }));

        it('should open the delete-confirm modal and handle cancel', fakeAsync(() => {

            mockModal.open = sinon.stub().returns({
                componentInstance: {},
                result: Promise.reject(null)
            });

            component.revokeIdentity({name: 'fred'});
            tick();

            mockAlertService.busyStatus$.next.should.not.have.been.called;
            mockAlertService.errorStatus$.next.should.not.have.been.called;
        }));

        it('should revoke the identity from the client service and then remove the identity from the wallet if in wallet', fakeAsync(() => {
            component['myIDs'] = [{ref: '1234', usable: true}];
            component['businessNetworkName'] = 'myNetwork';
            component['myIdentities'] = ['fred'];
            mockModal.open = sinon.stub().returns({
                componentInstance: {},
                result: Promise.resolve(true)
            });

            mockClientService.revokeIdentity.returns(Promise.resolve());

            let mockRemoveIdentity = sinon.stub(component, 'removeIdentity').returns(Promise.resolve());
            let mockLoadAllIdentities = sinon.stub(component, 'loadAllIdentities').returns(Promise.resolve());

            component.revokeIdentity({name: 'fred', ref: '1234'});

            tick();

            mockClientService.revokeIdentity.should.have.been.called;
            mockRemoveIdentity.should.have.been.calledWith('1234');
            mockLoadAllIdentities.should.have.been.called;

            mockAlertService.busyStatus$.next.should.have.been.called;
            mockAlertService.successStatus$.next.should.have.been.called;
        }));

        it('should handle error', fakeAsync(() => {
            mockModal.open = sinon.stub().returns({
                componentInstance: {},
                result: Promise.resolve(true)
            });

            mockClientService.revokeIdentity.returns(Promise.reject('some error'));

            let mockRemoveIdentity = sinon.stub(component, 'removeIdentity');
            let mockLoadAllIdentities = sinon.stub(component, 'loadAllIdentities');

            component.revokeIdentity({name: 'fred'});

            tick();

            mockClientService.revokeIdentity.should.have.been.called;
            mockRemoveIdentity.should.not.have.been.called;
            mockLoadAllIdentities.should.not.have.been.called;

            mockAlertService.busyStatus$.next.should.have.been.called;
            mockAlertService.errorStatus$.next.should.have.been.called;
        }));
    });

    describe('#loadParticipants', () => {

        it('should create a map of participants', fakeAsync(() => {

            // Set up mocked/known items to test against
            let mockParticpantRegistry = sinon.createStubInstance(ParticipantRegisty);
            let mockParticipant1 = sinon.createStubInstance(Resource);
            mockParticipant1.getFullyQualifiedIdentifier.returns('org.doge.Doge#DOGE_1');
            let mockParticipant2 = sinon.createStubInstance(Resource);
            mockParticipant2.getFullyQualifiedIdentifier.returns('org.doge.Doge#DOGE_2');
            mockParticpantRegistry.getAll.returns([mockParticipant2, mockParticipant1]);
            mockBusinessNetworkConnection = sinon.createStubInstance(BusinessNetworkConnection);
            mockBusinessNetworkConnection.getAllParticipantRegistries.returns(Promise.resolve([mockParticpantRegistry]));
            mockClientService.getBusinessNetworkConnection.returns(mockBusinessNetworkConnection);

            // Run method
            component['loadParticipants']();

            tick();

            // Check we load the participants
            let expected = new Map();
            expected.set('org.doge.Doge#DOGE_1', new Resource());
            expected.set('org.doge.Doge#DOGE_2', new Resource());
            component['participants'].should.deep.equal(expected);
        }));

        it('should alert if there is an error', fakeAsync(() => {

            // Force error
            mockBusinessNetworkConnection.getAllParticipantRegistries.returns(Promise.reject('some error'));
            mockClientService.getBusinessNetworkConnection.returns(mockBusinessNetworkConnection);

            // Run method
            component['loadParticipants']();

            tick();

            // Check we error
            mockAlertService.errorStatus$.next.should.be.called;
            mockAlertService.errorStatus$.next.should.be.calledWith('some error');

        }));
    });

    describe('#getParticipant', () => {
        it('should get the specified participant', () => {
            let mockParticipant1 = sinon.createStubInstance(Resource);
            mockParticipant1.getFullyQualifiedIdentifier.returns('org.doge.Doge#DOGE_1');
            mockParticipant1.getIdentifier.returns('DOGE_1');
            mockParticipant1.getType.returns('org.doge.Doge');
            let mockParticipant2 = sinon.createStubInstance(Resource);
            mockParticipant2.getFullyQualifiedIdentifier.returns('org.doge.Doge#DOGE_2');
            mockParticipant2.getIdentifier.returns('DOGE_2');
            mockParticipant2.getType.returns('org.doge.Doge');
            let mockParticipant3 = sinon.createStubInstance(Resource);
            mockParticipant3.getFullyQualifiedIdentifier.returns('org.doge.Doge#DOGE_3');
            mockParticipant3.getIdentifier.returns('DOGE_3');
            mockParticipant3.getType.returns('org.doge.Doge');

            component['participants'].set('DOGE_1', mockParticipant1);
            component['participants'].set('DOGE_2', mockParticipant2);

            let participant = component['getParticipant']('DOGE_2');

            participant.getIdentifier().should.equal('DOGE_2');
            participant.getType().should.equal('org.doge.Doge');
        });
    });
});
