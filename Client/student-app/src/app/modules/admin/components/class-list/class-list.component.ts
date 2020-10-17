import { Component, OnInit } from '@angular/core';
import { ClassListService } from '../../services/class-list.service';
import { CreateClass } from '../../models/Class/create-class';
import { NgbModal } from '@ng-bootstrap/ng-bootstrap';
import { FormGroup, FormBuilder } from '@angular/forms';
import { MainService } from '../../../../common/services/main.service';

@Component({
  selector: 'app-class-list',
  templateUrl: './class-list.component.html',
  styleUrls: ['./class-list.component.css'],
  providers:[ClassListService]
})
export class ClassListComponent implements OnInit {

  listClass:CreateClass[]
  config: any
  addClassForm:FormGroup
  semester:string
  constructor(private classService:ClassListService,
              private modalService: NgbModal,
              private mainService:MainService,
              private fb:FormBuilder) { 
    
    this.addClassForm=this.fb.group({
      secId:[''],
      semester:[''],
      status:[Number],
      building:[''],
      roomNumber:[''],
      startHr:[Number],startMin:[Number],
      endHr:[Number],endMin:[Number],
      courseId:[''],
      title:[''],
      capacity:[Number],
      name:['']
    })
    this.PageAction(event)
  }

  ngOnInit(): void {
    this.mainService.getNewestSemester().subscribe(res=>{
      this.semester=res
      this.GetAll(this.semester)
      
    })      
  }

  GetAll(semester){
    this.classService.GetAll(semester).subscribe(res=>{
        this.listClass=res
    })
  }

  SearchClass(term: string){
    
    if(term!=''){
       var st : CreateClass[]
       st = this.listClass.filter(x=>x.secId==term)                            
       if(st.length!=0){
         this.listClass.length = 0
         this.listClass=st
       }
    }
    else{
        this.GetAll(this.mainService.getNewestSemester())
    }
  }

  AddClass(){
    console.log('addclass has clicked')
  }

  PageAction(event){
    this.config = {
      itemsPerPage: 20,
      currentPage: 1,
      totalItems: this.listClass?.length
    }
    // call if page changed
    this.config.currentPage = event
  }

  ShowAddClass(newClass){
    this.modalService.open(newClass, { scrollable: true,size: 'xl' })
  }
}
