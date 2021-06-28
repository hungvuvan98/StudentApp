import { Component, OnInit } from '@angular/core';
import { AuthService } from '../../../shared/services/auth/auth.service';
import { MainService } from '../../../shared/services/main.service';
import { StudentFeeService } from './student-fee.service';

@Component({
  selector: 'app-student-fee',
  templateUrl: './student-fee.component.html',
  styleUrls: ['./student-fee.component.css'],
  providers:[StudentFeeService]
})
export class StudentFeeComponent implements OnInit {

  courseAndFees: any[];
  studentId:any;
  semester:any;
  totalFee:number=0;

  constructor(private service:StudentFeeService, private authService: AuthService,private mainService:MainService) { }

  ngOnInit(): void {
    this.authService.getUserId().subscribe(res=>{
      this.studentId=res;
      this.service.GetFees(this.studentId).subscribe(fee=>{
        this.courseAndFees=fee;
        this.TotalFee();
      });
    });
    this.mainService.getNewestSemester().subscribe(se=>{
      this.semester=se;
    })
  }

  TotalFee(){
    this.courseAndFees.forEach(element => {
        this.totalFee+= element.credit * element.fee;
    });
  }
}
