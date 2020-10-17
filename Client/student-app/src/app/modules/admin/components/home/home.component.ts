import { Component, OnInit } from '@angular/core';
import { MainService } from '../../../../common/services/main.service';

@Component({
  selector: 'app-home',
  templateUrl: './home.component.html',
  styleUrls: ['./home.component.css']
})
export class HomeComponent implements OnInit {

  constructor(private mainService:MainService) { }

  ngOnInit(): void {
    
  }

  setSemester(semester){
    this.mainService.setSemester(semester).subscribe(res=>console.log(res))   
  }
}
